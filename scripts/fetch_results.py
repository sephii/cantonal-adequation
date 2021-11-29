import asyncio
import enum
import itertools
import json
import os
import shutil
import sys
import tempfile
from dataclasses import dataclass
from typing import Any, Dict, List

import httpx

MAX_CONCURRENT_DOWNLOADS = 5
MIN_DATE = "2010-01-01"
METADATA_URL = "https://opendata.swiss/api/3/action/package_show?id=echtzeitdaten-am-abstimmungstag-zu-eidgenoessischen-abstimmungsvorlagen"
LANGUAGES = {"de", "fr"}


@enum.unique
class Canton(enum.Enum):
    ZH = 1
    BE = 2
    LU = 3
    UR = 4
    SZ = 5
    OW = 6
    NW = 7
    GL = 8
    ZG = 9
    FR = 10
    SO = 11
    BS = 12
    BL = 13
    SH = 14
    AR = 15
    AI = 16
    SG = 17
    GR = 18
    AG = 19
    TG = 20
    TI = 21
    VD = 22
    VS = 23
    NE = 24
    GE = 25
    JU = 26


@dataclass(frozen=True)
class VotationResult:
    yes: int
    no: int


@dataclass(frozen=True)
class VotationObject:
    id: int
    date: str
    titles: Dict[str, str]
    results: Dict[Canton, VotationResult]


def parse_votation_object(
    votation_object_dict: Dict[str, Any], votation_date: str
) -> VotationObject:
    title_by_language = {
        title["langKey"]: title["text"]
        for title in votation_object_dict["vorlagenTitel"]
        if title["langKey"] in LANGUAGES
    }
    results = {
        Canton(int(canton["geoLevelnummer"])): VotationResult(
            yes=canton["resultat"]["jaStimmenAbsolut"],
            no=canton["resultat"]["neinStimmenAbsolut"],
        )
        for canton in votation_object_dict["kantone"]
    }

    return VotationObject(
        id=votation_object_dict["vorlagenId"],
        date=votation_date,
        titles=title_by_language,
        results=results,
    )


def serialize_votation_object(votation_object: VotationObject) -> Dict[str, Any]:
    return {
        "id": votation_object.id,
        "date": votation_object.date,
        "titles": votation_object.titles,
        "results": {
            canton.name: {"yes": result.yes, "no": result.no}
            for canton, result in votation_object.results.items()
        },
    }


async def download_resource(
    *, dest_dir: str, id: str, url: str, semaphore: asyncio.Semaphore
) -> str:
    cache_file = os.path.join(dest_dir, id + ".json")

    if os.path.exists(cache_file):
        print(f"Skipping download of {url}, already cached in {cache_file}")
        return cache_file

    async with semaphore:
        print(f"Downloading file {url} ...")
        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers={"Accept": "application/json"})
            with open(cache_file, "w") as fd:
                # httpx wrongfully detects encoding as cp775 when using `response.text`
                fd.write(response.content.decode("utf-8"))

    return cache_file


async def parse_resource(file_path: str) -> List[VotationObject]:
    # utf-8-sig is needed because resource files contain a BOM mark
    with open(file_path, encoding="utf-8-sig") as fp:
        data = json.loads(fp.read())

    votation_date = data["abstimmtag"]
    # Resource dates are in format YYYYmmdd, add separators to make them more "standard"
    votation_date = f"{votation_date[:4]}-{votation_date[4:6]}-{votation_date[6:]}"

    objects = [
        parse_votation_object(votation_object, votation_date)
        for votation_object in data["schweiz"]["vorlagen"]
    ]

    return objects


async def download_json_files(
    *,
    metadata_url: str,
    max_concurrent_downloads: int,
    dest_dir: str,
    dest_file: str,
    min_date: str = None,
):
    """
    Download the initial metadata file located at `metadata_url` and all resources
    listed in it and save them in `dest_dir`.
    """
    semaphore = asyncio.Semaphore(max_concurrent_downloads)

    async with httpx.AsyncClient() as client:
        response = await client.get(
            metadata_url, headers={"Accept": "application/json"}
        )
        data = response.json()

        resources_urls = [
            (resource["id"], resource["download_url"])
            for resource in data["result"]["resources"]
            if resource["coverage"] >= min_date
        ]

        print(f"Found {len(resources_urls)} files to download")

        download_tasks = [
            asyncio.create_task(
                download_resource(
                    dest_dir=dest_dir,
                    id=resource_id,
                    url=resource_url,
                    semaphore=semaphore,
                )
            )
            for resource_id, resource_url in resources_urls
        ]
        paths = await asyncio.gather(*download_tasks)
        votation_objects_per_resource = await asyncio.gather(
            *[parse_resource(path) for path in paths]
        )

    votation_objects = itertools.chain.from_iterable(votation_objects_per_resource)

    with open(dest_file, "w") as fp:
        fp.write(
            json.dumps(
                [
                    serialize_votation_object(votation_object)
                    for votation_object in votation_objects
                ]
            )
        )


def main():
    dest_file = os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..", "results.json")
    )

    if len(sys.argv) > 1:
        dest_dir, auto_tmp_dir = sys.argv[1], False

        if not os.path.isdir(dest_dir):
            print(f"Destination directory {dest_dir} doesn’t exist. Please create it.")
            sys.exit(1)
    else:
        dest_dir, auto_tmp_dir = tempfile.mkdtemp(prefix="votation_results"), True

    try:
        print(f"Downloading files to {dest_dir} ...")

        loop = asyncio.get_event_loop()
        loop.run_until_complete(
            download_json_files(
                metadata_url=METADATA_URL,
                max_concurrent_downloads=MAX_CONCURRENT_DOWNLOADS,
                dest_dir=dest_dir,
                dest_file=dest_file,
                min_date=MIN_DATE,
            )
        )

        print(f"All done! Results extracted and stored in {dest_file} .")
        if not auto_tmp_dir:
            print(f"Downloaded results are available in {dest_dir} .")
    finally:
        if auto_tmp_dir:
            shutil.rmtree(dest_dir)


if __name__ == "__main__":
    main()

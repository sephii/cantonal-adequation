import os
import string

LANGUAGES = ("fr", "de")
TEMPLATE_VARS = {
    "og_description": {
        "fr": "Vous avez l’impression que personne ne vote comme vous dans votre région ? Vérifiez si vous êtes bien en adéquation politique avec votre canton de résidence.",
        "de": "Haben Sie den Eindruck, dass niemand wie Sie in Ihrer Region abstimmt? Kontrollieren Sie, ob Sie politisch im Einklang stehen mit Ihrem Wohnkanton.",
    },
    "og_image": {
        "fr": "https://adequation-cantonale.ch/assets/images/og_fr.png",
        "de": "https://kantonale-affinitaet.ch/assets/images/og_de.png",
    },
    "title": {
        "fr": "Vérifiez votre adéquation cantonale !",
        "de": "Überprüfen Sie Ihre kantonale Affinität!",
    },
    "og_title": {
        "fr": "Vérifiez votre adéquation cantonale !",
        "de": "Überprüfen Sie Ihre kantonale Affinität!",
    },
}

dest_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "dist"))

if __name__ == "__main__":
    with open("index.html") as fp:
        template = string.Template(fp.read())

    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)

    for language in LANGUAGES:
        template_vars = {
            template_var: translations[language]
            for template_var, translations in TEMPLATE_VARS.items()
        }
        with open(os.path.join(dest_dir, f"index_{language}.html"), "w") as fp:
            fp.write(template.safe_substitute({**template_vars, "language": language}))

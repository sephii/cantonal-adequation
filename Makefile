LANG := fr

all: assets html
	elm-optimize-level-2 src/Main.elm --output=dist/main.js
	esbuild --minify --pure:A2 --pure:A3 --pure:A4 --pure:A5 --pure:A6 --pure:A7 --pure:A8 --pure:A9 --pure:F2 --pure:F3 --pure:F3 --pure:F4 --pure:F5 --pure:F6 --pure:F7 --pure:F8 --pure:F9 dist/main.js | sponge dist/main.js

html: distdir
	python scripts/generate_html.py

results.json:
	mkdir -p /tmp/votation_results
	python scripts/fetch_results.py

serve: results.json assets html
	cp results.json dist/
	elm-live src/Main.elm -H --dir=dist --start-page=index_$(LANG).html -- --debug --output=dist/main.js

clean:
	rm -rf dist/

distdir:
	mkdir -p dist/

assets: distdir
	cp -r assets/ dist/

LANG := fr

all: assets html
	npx elm-optimize-level-2 src/Main.elm --output=dist/main.js
	npx terser dist/main.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | npx terser --mangle | sponge dist/main.js

html: distdir
	python scripts/generate_html.py

fetch: distdir
	mkdir -p /tmp/votation_results
	python scripts/fetch_results.py

serve: assets html
	elm-live src/Main.elm -H --dir=dist --start-page=index_$(LANG).html -- --debug --output=dist/main.js

clean:
	rm -rf dist/

distdir:
	mkdir -p dist/

assets: distdir
	cp -r assets/ dist/

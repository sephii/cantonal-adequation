# Check your cantonal adequation!

This is the source code of the website running on
https://adequation-cantonale.ch/ (FR) and https://kantonale-affinitaet.ch/ (DE).

## Local setup

To run the project locally, you’ll need [the Nix package
manager](https://nixos.org/guides/install-nix.html), so start by installing it.

If you don’t want to install Nix (you should really try it!), you can also
install the requirements manually (refer to the `shell.nix` file).

Once Nix is installed, follow these steps:

1. Clone the repository (`git clone https://github.com/sephii/cantonal-adequation`)
2. `cd` into it (`cd cantonal-adequation`)
3. Run a shell with the dependencies by running `nix-shell`
4. Download the votation results by running `make fetch`
5. Start the development server by running `make serve`
6. Point your web browser to http://localhost:8000/

If you want to serve the german version of the site, run `make serve LANG=de`.

## Building the site

To build it, follow the instructions in "Local setup", then run `make` (or `make
fetch all` if you want to update the votation results). The output will be
stored in the `dist/` directory, which you can then copy on a server.

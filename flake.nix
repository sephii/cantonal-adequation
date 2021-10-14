{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  description = "Website of https://adequation-cantonale.ch/";

  outputs = { self, nixpkgs, flake-utils }:
    let
      makePkg = { pkgs, additionalInputs ? [ ], pythonPackages ? (ps: [ ]) }:
        pkgs.stdenv.mkDerivation {
          name = "cantonal-adequation";
          src = ./.;
          buildPhase = pkgs.elmPackages.fetchElmDeps {
            elmPackages = import ./elm-srcs.nix;
            elmVersion = "0.19.1";
            registryDat = ./registry.dat;
          } + ''
            make
          '';
          installPhase = ''
            mkdir $out
            cp -r dist/* $out
          '';
          buildInputs = with pkgs;
            let pythonEnv = python38.withPackages (ps: [ ps.httpx ]);
            in [
              pythonEnv

              elmPackages.elm
              elmPackages.elm-live
              elmPackages.elm-optimize-level-2
              nodePackages.uglify-js

              esbuild
              # For sponge
              moreutils
            ] ++ (pythonPackages pythonEnv.pkgs) ++ additionalInputs;
        };
    in {
      overlay = final: prev: {
        cantonal-adequation = makePkg { pkgs = prev; };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        defaultPackage = makePkg { inherit pkgs; };
        devShell = makePkg {
          inherit pkgs;
          additionalInputs = [ pkgs.elmPackages.elm-live pkgs.elm2nix ];
        };
      });
}

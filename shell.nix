with import <nixpkgs> { };

let pythonEnv = python38.withPackages (ps: [ ps.httpx ]);
in mkShell {
  buildInputs = [
    pythonEnv
    pythonEnv.pkgs.python-language-server
    pythonEnv.pkgs.pyls-black
    pythonEnv.pkgs.pyls-isort

    elmPackages.elm
    elmPackages.elm-live
    elmPackages.elm-optimize-level-2

    esbuild
    # For sponge
    moreutils
  ];
}

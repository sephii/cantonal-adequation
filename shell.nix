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

    # For sponge
    moreutils
    # For uglifyjs
    nodejs-14_x
  ];
}

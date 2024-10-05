{ pkgs, name ? "pydev", extra ? [], pyVer ? "3" }:
let
  pythonPackages = pkgs.${"python${pyVer}Packages"};
in
  pkgs.mkShell {
    inherit name;
    venvDir = "./.venv";
    buildInputs = with pythonPackages; [
      python
      pkgs.ruff
      venvShellHook
      build
      pytest
    ] ++ builtins.map (x: pythonPackages.${x}) extra;
  }

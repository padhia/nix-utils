# nix-utils

A collection of personal nix utilities.

## mkPyFlake

Creates a standard attributes of a Python flake from simple specification.

Example:

```nix
    nix-utils.lib.mkPyFlake {
      pkgs     = { dbmake-duckdb = import ./dbmake-duckdb.nix; };
      deps     = [ "duckdb" "dbmake" ];
      apps     = [ "dkmake" "dkmake-refs" "dkmake-cache" "dkmake-gc" ];
      pyFlakes = [ dbmake ];
    };
```

Above snippet when placed in `outputs` section of a Nix flake, will
1. add any Python packages from other Nix flakes that are specified in `pyFlakes`
1. create Python package `dbmake-duckdb`
1. create `devShells` for each Python versions (currently defaults are `3.11` and `3.12`) and `devShells.default` attribute
1. create `Python3xPackages.<pkg>`
1. create `apps.<app>` for each application specified in `apps`
1. create `overlays.default` attribute

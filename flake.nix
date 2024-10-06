{
  description = "Library of Nix utility functions";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  {
    lib = rec {
      forAllSystems = import ./forAllSystems.nix;
      extendPyPkgsWith = import ./extendPyPkgsWith.nix;
      pyDevShell = import ./pyDevShell.nix;
      mkPyFlake = (import ./mkPyFlake.nix) { inherit nixpkgs forAllSystems; };
    };
  };
}

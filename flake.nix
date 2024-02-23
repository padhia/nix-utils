{
  description        = "Library of Nix utility functions";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: fn nixpkgs.legacyPackages.${system});
  in {
    lib = {
      inherit forAllSystems;
      mkPyFlake = (import ./mkPyFlake.nix) { inherit nixpkgs forAllSystems; };
    };
  };
}

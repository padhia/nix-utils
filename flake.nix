{
  description = "Library of Nix utility functions";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    inherit (nixpkgs.lib) genAttrs;

    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = args: fn:
      let
        forEachSystem = system:
          let
            pkgs = import nixpkgs ({
              inherit system;
              config.allowUnfree = true;
            } // args);
          in
            fn pkgs;
      in
        genAttrs systems forEachSystem;
  in {
    lib = {
      inherit forAllSystems;
      mkPyFlake = (import ./mkPyFlake.nix) { inherit nixpkgs forAllSystems; };
      pyDevShell = import ./pyDevShell.nix;
    };
  };
}

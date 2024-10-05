{
  nixpkgs,
  systems ? [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ]
}:
pkgAttrs: fn:
let
  forEachSystem = system:
    let
      pkgs = import nixpkgs ({
        inherit system;
        config.allowUnfree = true;
      } // pkgAttrs);
    in
      fn pkgs;
in
  nixpkgs.lib.genAttrs systems forEachSystem

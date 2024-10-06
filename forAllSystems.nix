pkgAttrs: fn:
let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  forEachSystem = system:
    let
      pkgs = import nixpkgs ({
        inherit system;
        config.allowUnfree = true;
      } // pkgAttrs);
    in
      fn pkgs;
in
  genAttrs systems forEachSystem

pkgs: pkgFiles:
let
  pyOverlay = py-final: py-prev: builtins.mapAttrs (name: file: py-final.callPackage file {}) pkgFiles;
in {
  pythonPackagesExtensions = pkgs.pythonPackagesExtensions ++ [ pyOverlay ];
}

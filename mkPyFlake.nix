{ nixpkgs, forAllSystems }:
args@ {
  pkgs,
  defaultPkg ? null,
  deps ? [],
  apps ? [],
  pyFlakes ? [],
  pythons ?  ["python311" "python312"]
}:

let
  callWithVars = fn: pkgs:
  let 
    python3 = pkgs.lib.elemAt pythons 0;

    defaultPkgName = with pkgs.lib;
      let
        pkgList = attrsToList args.pkgs;
        firstName = if (length pkgList) == 1 then (head pkgList).name else null;
      in
        if defaultPkg == null then firstName else defaultPkg;

    withDefault = xs: with pkgs.lib;
      let
        addDefault  = a: a // { default = a.${elemAt xs 0}; };
        makeDefault = mapAttrs' (k: v: nameValuePair "default" v);
      in
        if (length xs) == 0 then id else if (length xs) == 1 then makeDefault else addDefault;

    allDeps = py: pkgs.lib.foldl (x: y: x // y.packages.${pkgs.system}.${py + "Packages"}) pkgs.${py}.pkgs pyFlakes;

    pyPkgs = py: with pkgs.lib;
      let
        callPackage = callPackageWith (allDeps py);
        mkPkg       = name: builder: callPackage builder {};
      in mapAttrs mkPkg args.pkgs;
  in
    fn { inherit pkgs python3 defaultPkgName withDefault allDeps pyPkgs; };

  mkDevShells = { pkgs, defaultPkgName, allDeps, withDefault, ... }:
  let
    mkPyDevShell = py:
      pkgs.mkShell {
        name = if defaultPkgName == null then "python" else defaultPkgName;
        venvDir = "./.venv";
        buildInputs = with (allDeps py); [
          pkgs.${py}
          pkgs.ruff
          venvShellHook
          build
          pytest
        ] ++ (builtins.map (d: (allDeps py).${d}) deps);
      };
    allPys = pkgs.lib.genAttrs pythons mkPyDevShell;
  in
    withDefault pythons allPys;

  mkPackages = {pkgs, pyPkgs, defaultPkgName, python3, ...} : with pkgs.lib;
  let
    allPys  = genAttrs pythons pyPkgs;
    allPkgs = mapAttrs' (k: v: nameValuePair (k + "Packages") v) allPys;
  in
    allPkgs // optionalAttrs (defaultPkgName != null) { default = allPys.${python3}.${defaultPkgName}; };

  mkApps = params@{pkgs, withDefault, ...}: with pkgs.lib;
  let
    packages = mkPackages params;
    mkApp = appName: {
      type    = "app";
      program = "${packages.default}/bin/${appName}";
    };
    allApps = genAttrs apps mkApp;
  in 
    withDefault apps allApps;

  forAllSysWithVars = fn: forAllSystems (callWithVars fn);

in {
  devShells = forAllSysWithVars mkDevShells;
  packages  = forAllSysWithVars mkPackages;
  apps      = forAllSysWithVars mkApps;
  overlays.default = f: p: callWithVars ({pyPkgs, python3, ...}: pyPkgs python3) p;
}

{
  pkgs,
  pkg,
  cmds,
  makeFirstDefault ? true
}:
let
  inherit (pkgs.lib) genAttrs optionalAttrs;
  mkApp = cmd: { type = "app"; program = "${pkg}/bin/${cmd}"; };
in
  (genAttrs cmds mkApp) // optionalAttrs makeFirstDefault { default = mkApp (builtins.head cmds); }

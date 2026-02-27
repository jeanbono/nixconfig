{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.protonpass;
  braveCfg = config.modules.system.brave;
  protonPassId = "ghmbeldphafepmbegfdlkpapadhbakde";
in
{
  options.modules.system.protonpass.enable = lib.mkEnableOption "ProtonPass CLI + GUI";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      proton-pass
      proton-pass-cli
    ];

    # Installer l'extension Brave seulement si Brave est activé
    modules.system.brave.extraExtensions = lib.mkIf braveCfg.enable [
      "${protonPassId};https://clients2.google.com/service/update2/crx"
    ];
    modules.system.brave.extraPinnedExtensions = lib.mkIf braveCfg.enable [ protonPassId ];
  };
}

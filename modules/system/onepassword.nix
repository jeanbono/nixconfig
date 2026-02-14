{ lib, config, ... }:

let
  cfg = config.modules.system.onepassword;
  braveCfg = config.modules.system.brave;
  extensionId = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
in
{
  options.modules.system.onepassword.enable = lib.mkEnableOption "1Password CLI + GUI";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = braveCfg.enable;
      message = "modules.system.onepassword requires modules.system.brave to be enabled";
    }];

    programs._1password.enable = true;
    programs._1password-gui.enable = true;

    environment.etc."xdg/autostart/1password-silent.desktop".text = ''
      [Desktop Entry]
      Name=1Password (Silent)
      Exec=1password --silent
      Terminal=false
      Type=Application
      StartupNotify=false
    '';

    modules.system.brave.extraExtensions = [
      "${extensionId};https://clients2.google.com/service/update2/crx"
    ];
    modules.system.brave.extraPinnedExtensions = [ extensionId ];
  };
}

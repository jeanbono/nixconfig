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

    environment.etc."brave/policies/managed/01-1password.json".text = builtins.toJSON {
      ExtensionInstallForcelist = [
        "${extensionId};https://clients2.google.com/service/update2/crx"
      ];
    };
  };
}

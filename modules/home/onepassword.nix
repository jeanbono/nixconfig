{ lib, config, ... }:

let
  cfg = config.modules.home.onepassword;
  braveCfg = config.modules.home.brave;
  extensionId = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
in
{
  options.modules.home.onepassword.enable = lib.mkEnableOption "Extension 1Password pour Brave";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = braveCfg.enable;
      message = "modules.home.onepassword requires modules.home.brave to be enabled";
    }];

    home.file.".config/BraveSoftware/Brave-Browser/policies/managed/01-1password.json".text = builtins.toJSON {
      ExtensionInstallForcelist = [
        "${extensionId};https://clients2.google.com/service/update2/crx"
      ];
    };
  };
}

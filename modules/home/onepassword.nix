{ lib, config, ... }:

let
  cfg = config.modules.home.onepassword;
  braveCfg = config.modules.home.brave;
in
{
  options.modules.home.onepassword.enable = lib.mkEnableOption "Extension 1Password pour Brave";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = braveCfg.enable;
      message = "modules.home.onepassword requires modules.home.brave to be enabled";
    }];
  };
}

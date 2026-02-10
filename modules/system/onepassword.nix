{ lib, config, ... }:

let
  cfg = config.modules.system.onepassword;
in
{
  options.modules.system.onepassword.enable = lib.mkEnableOption "1Password CLI + GUI";

  config = lib.mkIf cfg.enable {
    programs._1password.enable = true;
    programs._1password-gui.enable = true;
  };
}

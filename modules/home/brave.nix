{ lib, config, ... }:

let
  cfg = config.modules.home.brave;
in
{
  options.modules.home.brave.enable = lib.mkEnableOption "Brave browser + policies hardening";

  config = lib.mkIf cfg.enable {
    programs.brave.enable = true;

    home.file.".config/BraveSoftware/Brave-Browser/policies/managed/00-hardening.json".text = builtins.toJSON {
      BraveRewardsDisabled = true;
      BraveWalletDisabled = true;
      BraveVPNDisabled = true;
      TorDisabled = true;
      BraveAIChatEnabled = false;
    };
  };
}

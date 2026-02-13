{ lib, config, ... }:

let
  cfg = config.modules.system.brave;
in
{
  options.modules.system.brave.enable = lib.mkEnableOption "Brave browser policies (system-level)";

  config = lib.mkIf cfg.enable {
    environment.etc."brave/policies/managed/00-hardening.json".text = builtins.toJSON {
      BraveRewardsDisabled = true;
      BraveWalletDisabled = true;
      BraveVPNDisabled = true;
      TorDisabled = true;
      BraveAIChatEnabled = false;
    };
  };
}

{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.network;
in
{
  options.modules.system.network.enable = lib.mkEnableOption "NetworkManager et SSH";

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
    services.openssh.enable = true;

    environment.systemPackages = with pkgs; [
      curl
      wget
    ];
  };
}

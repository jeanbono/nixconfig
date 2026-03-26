{ pkgs, lib, config, ... }:

let
  cfg = config.modules.network;
in
{
  options.modules.network.enable = lib.mkEnableOption "NetworkManager et SSH";

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
    systemd.services.NetworkManager-wait-online.enable = true;
    services.openssh.enable = true;

    environment.systemPackages = with pkgs; [
      curl
      wget
    ];
  };
}

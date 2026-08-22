{
  den.aspects.network.nixos = { pkgs, ... }: {
    networking.networkmanager.enable = true;
    systemd.services.NetworkManager-wait-online.enable = true;
    services.openssh.enable = true;

    environment.systemPackages = with pkgs; [
      curl
      wget
    ];
  };
}

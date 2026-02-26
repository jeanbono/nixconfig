{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.gaming;
in
{
  options.modules.system.gaming.enable = lib.mkEnableOption "Steam, Proton, MangoHud, Gamemode, Wine";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    programs.gamemode.enable = true;

    # Outils utiles (optionnels)
    environment.systemPackages = with pkgs; [
      mangohud
      gamemode
      protonplus
      vulkan-tools
      wineWow64Packages.stable
      winetricks
      # Support NTFS pour les jeux Windows
      ntfs3g
    ];

    hardware.graphics.enable32Bit = true;
    hardware.steam-hardware.enable = true;
  };
}

{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.gaming;
in
{
  options.modules.system.gaming.enable = lib.mkEnableOption "Steam, Proton, MangoHud, Gamemode, Wine";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      # Active les libs 32-bit nécessaires à pas mal de jeux
      # (Steam Runtime / Proton)
    };

    # Outils utiles (optionnels)
    environment.systemPackages = with pkgs; [
      mangohud
      gamemode
      protonplus
      vulkan-tools
      wineWow64Packages.stable
    ];

    programs.gamemode.enable = true;

    # 32-bit OpenGL/Vulkan pour Proton/jeux
    hardware.graphics.enable32Bit = true;
  };
}

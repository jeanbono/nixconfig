{ pkgs, ... }:

{
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
    wineWowPackages.stable
  ];

  programs.gamemode.enable = true;

  # 32-bit OpenGL/Vulkan pour Proton/jeux
  hardware.graphics.enable32Bit = true;
}

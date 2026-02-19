{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hypridle      # Verrouillage automatique après inactivité
      wofi          # Lanceur d'applications + menu d'extinction
      wl-clipboard  # Copier/coller Wayland
      grim          # Capture d'écran
      slurp         # Sélection de zone
      pavucontrol   # Contrôle audio
      brightnessctl # Luminosité
      hyprcursor    # Support curseurs modernes
      hyprshutdown  # Handle graceful shutdown
    ];
  };
}

{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.hyprland;
  plasmaCfg = config.modules.system.plasma;
in
{
  options.modules.system.hyprland.enable = lib.mkEnableOption "Hyprland (Wayland compositor) + portails + polices";

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = !plasmaCfg.enable;
      message = "modules.system.hyprland et modules.system.plasma sont mutuellement exclusifs";
    }];

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Variables d'environnement Nvidia pour Hyprland
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    # Portails XDG (nécessaires pour screensharing, file picker, etc.)
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Display manager : greetd + tuigreet (léger, Wayland-natif)
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
          user = "greeter";
        };
      };
    };

    fonts.packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    fonts.fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "none";
        lcdfilter = "default";
      };
    };
  };
}

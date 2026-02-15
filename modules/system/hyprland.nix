{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.hyprland;
  plasmaCfg = config.modules.system.plasma;

  # Config Hyprland minimale pour le greeter ReGreet
  greetdHyprlandConfig = pkgs.writeText "greetd-hyprland.conf" ''
    monitor = DP-3, 2560x1440@165, 0x0, 1
    monitor = DP-1, 2560x1440@300, 2560x0, 1

    input {
      kb_layout = fr
    }

    misc {
      force_default_wallpaper = 0
      disable_hyprland_logo = true
      disable_watchdog_warning = true
    }

    cursor {
      no_hardware_cursors = true
    }

    env = LIBVA_DRIVER_NAME,nvidia
    env = __GLX_VENDOR_LIBRARY_NAME,nvidia

    exec-once = ${lib.getExe pkgs.regreet}; hyprctl dispatch exit
  '';
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
      withUWSM = true;
    };

    # Masquer la session Hyprland classique (garder uniquement uwsm-managed)
    environment.etc."wayland-sessions/hyprland.desktop".text = lib.mkForce "";

    # Variables d'environnement Nvidia pour Hyprland
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    # Portails XDG (nécessaires pour screensharing, file picker, etc.)
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Display manager : greetd + ReGreet dans une session Hyprland
    programs.regreet = {
      enable = true;
      settings = {
        background = {
          fit = "Cover";
        };
        GTK = {
          application_prefer_dark_theme = true;
        };
      };
      font = {
        name = "FiraCode Nerd Font";
        size = 14;
      };
      cursorTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
    };

    # Remplacer cage par Hyprland pour le greeter (multi-écran + clavier FR)
    services.greetd.settings.default_session.command = lib.mkForce
      "${config.programs.hyprland.package}/bin/Hyprland --config ${greetdHyprlandConfig}";

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

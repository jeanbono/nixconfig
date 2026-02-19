{ lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
  themeCfg = config.modules.home.theme.catppuccin;
  iconsDir = themeCfg.wlogoutIconsDir;
  themeCSS = builtins.readFile themeCfg.wlogoutThemeFile;
in
{
  config = lib.mkIf cfg.enable {
    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "logout";
          action = "hyprshutdown -t 'Logging out...'";
          text = "Logout";
          keybind = "l";
        }
        {
          label = "reboot";
          action = "hyprshutdown -t 'Restarting...' --post-cmd 'reboot'";
          text = "Reboot";
          keybind = "r";
        }
        {
          label = "shutdown";
          action = "hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'";
          text = "Shutdown";
          keybind = "s";
        }
      ];
      style = ''
        ${themeCSS}

        #logout {
            background-image: url("${iconsDir}/logout.svg");
        }
        #reboot {
            background-image: url("${iconsDir}/reboot.svg");
        }
        #shutdown {
            background-image: url("${iconsDir}/shutdown.svg");
        }
      '';
    };
  };
}

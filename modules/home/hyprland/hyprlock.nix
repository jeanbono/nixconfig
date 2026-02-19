{ lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
          grace = 5;
        };

        background = [{
          path = "~/wallpaper.png";
          blur_passes = 3;
          blur_size = 8;
        }];

        input-field = [{
          size = "250, 50";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.15;
          outer_color = "$mauve";
          inner_color = "$base";
          font_color = "$text";
          fade_on_empty = false;
          placeholder_text = "Mot de passe...";
          fail_text = "Incorrect";
          halign = "center";
          valign = "center";
          font_family = "MonaspiceNe Nerd Font";
        }];

        label = [{
          text = "cmd[update:1000] date +\"%H:%M\"";
          color = "$text";
          font_size = 64;
          font_family = "MonaspiceNe Nerd Font";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }];
      };
    };
  };
}

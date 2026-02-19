{ lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
  themeCfg = config.modules.home.theme.catppuccin;
in
{
  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          monitor = "DP-1";
          follow = "mouse";
          width = 350;
          height = 200;
          origin = "top-right";
          offset = "10x10";
          indicate_hidden = "yes";
          separator_height = 2;
          padding = 10;
          horizontal_padding = 12;
          frame_width = 2;
          separator_color = "frame";
          sort = "yes";
          font = "MonaspiceNe Nerd Font 11";
          line_height = 2;
          markup = "full";
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 60;
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";
          icon_position = "left";
          max_icon_size = 32;
          sticky_history = "yes";
          history_length = 20;
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          startup_notification = false;
          corner_radius = 8;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action";
          mouse_right_click = "close_all";
        };

        urgency_low = {
          timeout = 5;
        };

        urgency_normal = {
          timeout = 10;
        };

        urgency_critical = {
          timeout = 0;
        };
      };

      settings.global.include = themeCfg.dunstThemeFile;
    };
  };
}

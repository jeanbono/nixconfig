{ lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          monitor = "DP-1";
          follow = "mouse";
          geometry = "300x5-30+20";
          indicate_hidden = "yes";
          shrink = "no";
          transparency = 20;
          notification_height = 0;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          frame_width = 2;
          frame_color = "$blue";
          separator_color = "$blue";
          sort = "yes";
          idle_threshold = 120;
          font = "MonaspiceNe Nerd Font 11";
          line_height = 0;
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
          browser = "brave";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          startup_notification = false;
          verbosity = "mesg";
          corner_radius = 8;
          force_xinerama = false;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action";
          mouse_right_click = "close_all";
        };

        urgency_low = {
          background = "$base";
          foreground = "$text";
          frame_color = "$sky";
          timeout = 10;
        };

        urgency_normal = {
          background = "$base";
          foreground = "$text";
          frame_color = "$blue";
          timeout = 10;
        };

        urgency_critical = {
          background = "$base";
          foreground = "$text";
          frame_color = "$red";
          timeout = 0;
        };
      };
    };
  };
}

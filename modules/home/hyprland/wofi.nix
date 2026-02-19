{ lib, config, ... }:

let
  cfg = config.modules.home.hyprland;
  t = config.modules.home.theme.catppuccin;
  p = t.palette;
  rgba = t.rgba;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."wofi/style.css".text = ''
      window {
        margin: 0;
        border: 2px solid ${rgba p.blue 0.4};
        border-radius: 12px;
        background-color: ${rgba p.base 0.92};
        font-family: "MonaspiceNe Nerd Font", "Noto Sans", sans-serif;
        font-size: 14px;
      }

      #input {
        margin: 8px;
        padding: 8px 12px;
        border: none;
        border-radius: 8px;
        background-color: ${p.surface0};
        color: ${p.text};
      }

      #input:focus {
        border: 2px solid ${rgba p.blue 0.5};
      }

      #inner-box {
        margin: 0 8px 8px 8px;
      }

      #outer-box {
        margin: 0;
        padding: 0;
      }

      #entry {
        padding: 6px 12px;
        border-radius: 8px;
        color: ${p.subtext1};
      }

      #entry:selected {
        background-color: ${rgba p.blue 0.2};
        color: ${p.text};
      }

      #entry:hover {
        background-color: ${rgba p.blue 0.1};
      }

      #entry image {
        margin-right: 10px;
      }

      #text {
        color: ${p.subtext1};
      }

      #text:selected {
        color: ${p.text};
      }
    '';

    xdg.configFile."wofi/config".text = ''
      width=500
      height=350
      show=drun
      prompt=Rechercher...
      allow_markup=true
      insensitive=true
      columns=1
      hide_scroll=true
      matching=fuzzy
      sort_order=alphabetical
      allow_images=true
      image_size=20
      term=kitty
      no_actions=true
    '';
  };
}

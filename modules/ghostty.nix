{ inputs, ... }:
{
  den.aspects.ghostty.homeManager = { ... }: {
    programs.ghostty = {
      enable = true;
      settings = {
        background-opacity = 0.96;
        window-padding-x = 10;
        window-padding-y = 10;
        font-family = inputs.self.lib.theme.font;
        cursor-style = "block";
        cursor-style-blink = false;
        gtk-single-instance = true;
        quit-after-last-window-closed = true;
        quit-after-last-window-closed-delay = "5m";
        # Close terminals without an interactive confirmation prompt.
        confirm-close-surface = false;
      };
    };
  };
}

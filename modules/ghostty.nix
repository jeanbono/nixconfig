{ inputs, ... }:
{
  den.aspects.ghostty.homeManager = { ... }: {
    programs.ghostty = {
      enable = true;
      settings = {
        theme = inputs.self.lib.theme.ghosttyTheme;
        background-opacity = 0.96;
        window-padding-x = 10;
        window-padding-y = 10;
        font-family = "MonaspiceNe Nerd Font";
        cursor-style = "block";
        cursor-style-blink = false;
        gtk-single-instance = true;
        quit-after-last-window-closed = true;
        quit-after-last-window-closed-delay = "5m";
        # Default (true) shows an in-window "confirm close?" dialog when a
        # foreground process is running — hyprshutdown can't interact with
        # that dialog, so it hangs waiting for the window to actually close
        # (e.g. logout with a `claude` session running in a Ghostty tab).
        confirm-close-surface = false;
      };
    };
  };
}

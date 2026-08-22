{ inputs, ... }:
{
  den.aspects.alacritty.homeManager = { pkgs, ... }: {
    programs.alacritty = {
      enable = true;
      settings = {
        general.import = [ (inputs.self.lib.theme.alacrittyThemeFile { inherit pkgs; }) ];
        window = {
          opacity = 0.96;
          padding = { x = 10; y = 10; };
        };
        font.normal.family = "MonaspiceNe Nerd Font";
        cursor = {
          style = "Block";
          blink_interval = 0;
        };
      };
    };
  };
}

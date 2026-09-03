{ inputs, ... }:
{
  den.aspects.messaging.homeManager = { pkgs, ... }: {
    programs.vesktop = {
      enable = true;
      vencord.themes.catppuccin = pkgs.fetchurl {
        url = "https://catppuccin.github.io/discord/dist/catppuccin-${inputs.self.lib.theme.flavor}.theme.css";
        # Hash is flavor-specific — update it if inputs.self.lib.theme.flavor changes.
        sha256 = "sha256-dHQhESjRhvlO24uzqgpQU+WYdkd93er2HNx8rJt6YbI=";
      };
      vencord.settings = {
        autoUpdate = true;
        autoUpdateNotification = true;
        notifyAboutUpdates = true;
        useQuickCss = true;
        enabledThemes = [ "catppuccin.css" ];
        plugins = {
          ClearURLs.enabled = true;
          FixYoutubeEmbeds.enabled = true;
        };
      };
    };

    home.packages = with pkgs; [ element-desktop cinny-desktop ];
  };
}

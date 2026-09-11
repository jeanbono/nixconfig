{ inputs, ... }:
{
  den.aspects.messaging.homeManager = { pkgs, ... }: {
    programs.vesktop = {
      enable = true;
      vencord.themes.catppuccin = pkgs.fetchurl {
        # Pin the compiled CSS from gh-pages so a fresh build can fetch it
        # even after the published website changes.
        url = "https://raw.githubusercontent.com/catppuccin/discord/0d8c7aaea33c655bb9e4c93d352a28f3baa69a75/dist/catppuccin-${inputs.self.lib.theme.flavor}.theme.css";
        # Hash is flavor-specific — update it if inputs.self.lib.theme.flavor changes.
        sha256 = "sha256-dHQhESjRhvlO24uzqgpQU+WYdkd93er2HNx8rJt6YbI=";
      };
      vencord.settings = {
        # Version pinned by the vesktop package in nixpkgs, not by Vencord
        # itself — leaves state changes to `nix flake update`.
        autoUpdate = false;
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

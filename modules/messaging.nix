{
  den.aspects.messaging.homeManager = { pkgs, ... }: {
    programs.vesktop = {
      enable = true;
      vencord.settings = {
        # Version pinned by the vesktop package in nixpkgs, not by Vencord
        # itself — leaves state changes to `nix flake update`.
        autoUpdate = false;
        autoUpdateNotification = true;
        notifyAboutUpdates = true;
        useQuickCss = true;
        plugins = {
          ClearURLs.enabled = true;
          FixYoutubeEmbeds.enabled = true;
        };
      };
    };

    home.packages = with pkgs; [ element-desktop cinny-desktop ];
  };
}

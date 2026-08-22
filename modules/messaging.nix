{
  den.aspects.messaging.homeManager = { pkgs, ... }: {
    programs.vesktop = {
      enable = true;
      vencord.settings = {
        autoUpdate = true;
        autoUpdateNotification = true;
        notifyAboutUpdates = true;
        plugins = {
          ClearURLs.enabled = true;
          FixYoutubeEmbeds.enabled = true;
        };
      };
    };

    home.packages = with pkgs; [ element-desktop cinny-desktop ];
  };
}

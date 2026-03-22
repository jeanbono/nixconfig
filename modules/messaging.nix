{ pkgs, lib, config, ... }:

let
  cfg = config.modules.messaging;
in
{
  options.modules.messaging.enable = lib.mkEnableOption "Discord, Element";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (_: {
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

      home.packages = with pkgs; [ element-desktop ];
    });
  };
}

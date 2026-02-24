{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.messaging;
in
{
  options.modules.home.messaging.enable = lib.mkEnableOption "Discord, Zulip, Element";

  config = lib.mkIf cfg.enable {
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

    home.packages = with pkgs; [
      zulip
      element-desktop
    ];
  };
}

{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.messaging;
in
{
  options.modules.home.messaging.enable = lib.mkEnableOption "Discord, Zulip, Element";

  config = lib.mkIf cfg.enable {
    programs.discord.enable = true;

    home.packages = with pkgs; [
      zulip
      element-desktop
    ];
  };
}

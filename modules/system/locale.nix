{ lib, config, ... }:

let
  cfg = config.modules.system.locale;
in
{
  options.modules.system.locale.enable = lib.mkEnableOption "Locale FR et clavier français";

  config = lib.mkIf cfg.enable {
    i18n.defaultLocale = "fr_FR.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
    console.keyMap = "fr";
    services.xserver.xkb = {
      layout = "fr";
      variant = "";
    };
  };
}

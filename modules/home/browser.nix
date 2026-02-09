{ lib, config, ... }:

let
  cfg = config.modules.home.browser;
in
{
  options.modules.home.browser.enable = lib.mkEnableOption "Brave browser";

  config = lib.mkIf cfg.enable {
    programs.brave.enable = true;
  };
}

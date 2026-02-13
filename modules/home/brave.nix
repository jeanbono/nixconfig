{ lib, config, ... }:

let
  cfg = config.modules.home.brave;
in
{
  options.modules.home.brave.enable = lib.mkEnableOption "Brave browser + policies hardening";

  config = lib.mkIf cfg.enable {
    programs.brave.enable = true;
  };
}

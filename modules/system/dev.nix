{ lib, config, ... }:

let
  cfg = config.modules.system.dev;
in
{
  options.modules.system.dev.enable = lib.mkEnableOption "Environnement de développement (Java)";

  config = lib.mkIf cfg.enable {
    programs.java.enable = true;
  };
}

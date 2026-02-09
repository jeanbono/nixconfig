{ lib, config, ... }:

let
  cfg = config.modules.system.printing;
in
{
  options.modules.system.printing.enable = lib.mkEnableOption "Impression (CUPS)";

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
  };
}

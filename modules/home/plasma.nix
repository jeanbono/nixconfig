{ lib, config, ... }:

let
  cfg = config.modules.home.plasma;
in
{
  options.modules.home.plasma.enable = lib.mkEnableOption "Config Plasma côté user (placeholder)";

  config = lib.mkIf cfg.enable {
    # Rien d'obligatoire ici, mais pratique pour des variables de session,
    # raccourcis, etc. (plasma-manager existe, mais c'est un autre input).
  };
}

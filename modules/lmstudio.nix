{ pkgs, lib, config, ... }:

let
  cfg = config.modules.lmstudio;
in
{
  options.modules.lmstudio.enable = lib.mkEnableOption "LM Studio";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (_: {
      home.packages = [ pkgs.lmstudio ];
    });

    networking.firewall.allowedTCPPorts = [ 1234 ];
  };
}

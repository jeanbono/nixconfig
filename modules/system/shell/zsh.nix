{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.zsh;
in
{
  options.modules.system.zsh.enable = lib.mkEnableOption "Zsh (niveau système)";

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
      git
      curl
      wget
    ];
  };
}

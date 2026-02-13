{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.dev;
in
{
  options.modules.home.dev.enable = lib.mkEnableOption "Outils de développement (IntelliJ IDEA)";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      jetbrains.idea
    ];

    programs = {
      vscode.enable = true;
    };
  };
}

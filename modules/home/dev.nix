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

    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
        ];
        userSettings = {
          "workbench.colorTheme" = "Catppuccin Macchiato";
          "workbench.iconTheme" = "catppuccin-macchiato";
        };
      };
    };
  };
}

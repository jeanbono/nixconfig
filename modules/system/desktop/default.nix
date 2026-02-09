{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.fonts;
in
{
  imports = [ ./plasma-wayland.nix ];

  options.modules.system.fonts.enable = lib.mkEnableOption "Polices (Nerd Fonts, Noto)";

  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];
  };
}

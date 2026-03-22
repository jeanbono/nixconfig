{ pkgs, lib, config, ... }:

let
  cfg = config.modules.intellij;
in
{
  options.modules.intellij.enable = lib.mkEnableOption "IntelliJ IDEA + Java";

  config = lib.mkIf cfg.enable {
    programs.java.enable = true;

    home-manager.users = lib.genAttrs config.modules.users (_: {
      home.packages = with pkgs; [ jetbrains.idea ];
    });
  };
}

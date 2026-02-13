{ config, pkgs, lib, hostName, ... }:

{
  imports = [
    ../../modules/home
  ];

  # --- Modules home composables ---
  modules.home = {
    shell.enable = true;
    git.enable = true;
    ssh.enable = true;
    brave.enable = true;
    messaging.enable = true;
    desktop.enable = true;
    dev.enable = true;
  };

  home.username = "pierre";
  home.homeDirectory = "/home/pierre";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}

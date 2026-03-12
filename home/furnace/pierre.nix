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
    tools.enable = true;
    dev.enable = true;
    nvim.enable = true;
    hyprland.enable = true;
    theme.catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "blue";
    };
  };

  programs.caelestia = {
    enable = true;
    systemd.enable = true;
    cli.enable = true;
    settings = {
      bar.status.showBattery = false;
      bar.status.showWifi = false;
    };
  };

  home.username = "pierre";
  home.homeDirectory = "/home/pierre";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}

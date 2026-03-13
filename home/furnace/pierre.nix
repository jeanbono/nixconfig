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
      general.idle.lockBeforeSleep = false;
      general.idle.timeouts = [
        { timeout = 300; idleAction = "lock"; }
        { timeout = 600; idleAction = "dpms off"; returnAction = "dpms on"; }
      ];
      appearance.rounding.scale = 0.6;
      session.commands.logout = ["hyprctl" "dispatch" "exec" "hyprshutdown -t 'Logging out...'"];
      session.commands.shutdown = ["hyprctl" "dispatch" "exec" "hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'"];
      session.commands.reboot = ["hyprctl" "dispatch" "exec" "hyprshutdown -t 'Restarting...' --post-cmd 'reboot'"];
    };
  };

  home.username = "pierre";
  home.homeDirectory = "/home/pierre";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}

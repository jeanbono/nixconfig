{ config, pkgs, lib, ... }:

let
  username = "pierre";
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # --- Modules système composables ---
  modules.system = {
    nix.enable = true;
    locale.enable = true;
    network.enable = true;
    audio.enable = true;
    printing.enable = true;
    plasma.enable = true;
    nvidia.enable = true;
    gaming.enable = true;
  };

  networking.hostName = "furnace";
  time.timeZone = "Europe/Paris";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "atlantic" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  users.users.pierre = {
    isNormalUser = true;
    description = "Pierre";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.zsh;
  };

  home-manager.users.pierre = import ../../home/furnace/pierre.nix;

  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
    java.enable = true;
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    pciutils
    usbutils
    jetbrains.idea
  ];

  fonts.fontconfig = {
    enable = true;

    antialias = true;

    hinting = {
      enable = true;
      style = "slight";   # ou "full" si tu préfères plus net
    };

    subpixel = {
      rgba = "none";      # IMPORTANT pour Wayland
      lcdfilter = "default";
    };
  };

  environment.etc."brave/policies/managed/00-hardening.json".text = ''
    {
      "BraveRewardsDisabled": true,
      "BraveWalletDisabled": true,
      "BraveVPNDisabled": true,
      "TorDisabled": true,
      "BraveAIChatEnabled": false
    }
  '';

  system.stateVersion = "25.05";
}

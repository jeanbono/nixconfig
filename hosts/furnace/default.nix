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
    brave.enable = true;
    onepassword.enable = true;
    shell.enable = true;
    dev.enable = true;
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

  environment.systemPackages = with pkgs; [
    vim
    git
    pciutils
    usbutils
  ];

  system.stateVersion = "25.05";
}

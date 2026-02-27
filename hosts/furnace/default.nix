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
    hyprland.enable = true;
    hyprland.user = username;
    nvidia.enable = true;
    gaming.enable = true;
    brave.enable = true;
    protonpass.enable = true;
    shell.enable = true;
    dev.enable = true;
  };

  networking.hostName = "furnace";
  time.timeZone = "Europe/Paris";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "atlantic" ];
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.zsh;
  };

  home-manager.users.${username} = import ../../home/furnace/${username}.nix;

  environment.systemPackages = with pkgs; [
    git
    pciutils
    usbutils
  ];

  # nix-ld: permet aux binaires standards de fonctionner sur NixOS
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Bibliothèques de base (essentielles)
    stdenv.cc.cc
    zlib
    glib
    pango
    cairo
    atk
    gdk-pixbuf
    gtk3
    # Bibliothèques X11
    libX11
    libXext
    libXi
    libXrender
    libXtst
    libXxf86vm
    # Polices
    fontconfig
    freetype
    # Réseau et SSL (souvent nécessaire pour les outils de développement)
    openssl
    curl
    nss
    nspr
  ];

  # Montage automatique de la partition Data Windows pour Steam
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/AE90AB7C90AB4A23";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "umask=002" "nofail" ];
  };

  system.stateVersion = "25.05";
}

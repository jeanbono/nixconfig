{ config, pkgs, lib, ... }:

let
  username = "pierre";
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # --- Utilisateurs gérés par les modules features ---
  modules.users = [ username ];

  # --- Modules features (NixOS + HM unifiés) ---
  modules = {
    nix.enable = true;
    locale.enable = true;
    network.enable = true;
    audio.enable = true;
    printing.enable = true;
    nvidia.enable = true;
    gaming.enable = true;

    hyprland.enable = true;
    hyprland.user = username;

    brave.enable = true;
    protonpass.enable = true;

    zsh.enable = true;
    alacritty.enable = true;
    git.enable = true;
    jujutsu.enable = true;
    ssh.enable = true;
    messaging.enable = true;
    tools.enable = true;
    claude-code.enable = true;
    intellij.enable = true;
    nvim.enable = true;
    caelestia.enable = true;

    theme.catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "blue";
    };
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

  home-manager.users.${username} = {
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "25.05";
    programs.home-manager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    glib
    pango
    cairo
    atk
    gdk-pixbuf
    gtk3
    libX11
    libXext
    libXi
    libXrender
    libXtst
    libXxf86vm
    fontconfig
    freetype
    openssl
    curl
    nss
    nspr
  ];

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/AE90AB7C90AB4A23";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "umask=002" "nofail" ];
  };

  system.stateVersion = "25.05";
}

{ config, pkgs, lib, ... }:

let
  cfg = config.modules.system.core;
in
{
  imports = [
    ./nix.nix
  ];

  options.modules.system.core.enable = lib.mkEnableOption "Core system config (locale FR, réseau, audio, SSH, paquets de base)";

  config = lib.mkIf cfg.enable {
    i18n.defaultLocale = "fr_FR.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
    console.keyMap = "fr";
    services.xserver.xkb = {
      layout = "fr";
      variant = "";
    };

    networking.networkmanager.enable = true;

    services.printing.enable = true;

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    environment.systemPackages = with pkgs; [
      vim
      wget
      curl
      git
      pciutils
      usbutils
    ];

    services.openssh.enable = true;
  };
}

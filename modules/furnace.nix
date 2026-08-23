{ inputs, den, ... }:
{
  den.aspects.furnace = {
    includes = [
      den.aspects.audio
      den.aspects.gaming
      den.aspects.locale
      den.aspects.network
      den.aspects.nix
      den.aspects.nvidia

      den.aspects.lmstudio
      den.aspects.intellij
      den.aspects.printing

      den.aspects.brave
      den.aspects.protonpass

      den.aspects.hyprland

      den.aspects.ollama
      den.aspects.zsh
    ];

    nixos = { pkgs, ... }: {
      imports = [ ./_nixos/hardware-configuration.nix ];

      nixpkgs.overlays = [ inputs.cachyos.overlays.pinned ];

      networking.hostName = "furnace";
      time.timeZone = "Europe/Paris";

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 25;
      };

      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.configurationLimit = 1;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelModules = [ "atlantic" ];
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

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
    };
  };
}

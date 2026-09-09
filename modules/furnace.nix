{ inputs, den, ... }:
{
  den.aspects.furnace = {
    includes = [
      den.batteries.hostname

      den.aspects.audio
      den.aspects.gaming
      den.aspects.locale
      den.aspects.network
      den.aspects.nix
      den.aspects.nvidia
      den.aspects.razer

      den.aspects.lmstudio
      den.aspects.intellij
      den.aspects.printing

      den.aspects.brave
      den.aspects.protonpass

      den.aspects.hyprland

      den.aspects.zsh
    ];

    nixos = { pkgs, config, ... }: {
      imports = [ ./_nixos/hardware-configuration.nix ];

      nixpkgs.overlays = [ inputs.cachyos.overlays.pinned ];

      time.timeZone = "Europe/Paris";

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 25;
      };

      boot.loader.systemd-boot.enable = false;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.limine = {
        enable = true;
        maxGenerations = 2;
        extraEntries = ''
          /Windows
            protocol: efi
            path: boot():///EFI/Microsoft/Boot/bootmgfw.efi
        '';
      };
      boot.kernelModules = [ "atlantic" ];
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

      environment.systemPackages = with pkgs; [
        pciutils
        usbutils
      ];

      # stdenv.cc.cc, zlib, curl, openssl are already in the module's own
      # default library set — only list what that default doesn't cover.
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
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
        nss
        nspr
      ];

      fileSystems."/mnt/data" = {
        device = "/dev/disk/by-uuid/AE90AB7C90AB4A23";
        fsType = "ntfs-3g";
        options = [
          "rw"
          "uid=${toString config.users.users.pierre.uid}"
          "gid=100" # standard "users" group, not user-specific
          "umask=002"
          "nofail"
        ];
      };
    };
  };
}

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
      den.aspects.greeter

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
      # Keep kernels on the ext4 root; the 200 MiB ESP only holds EFI loaders.
      boot.loader.efi.efiSysMountPoint = "/boot/efi";
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        configurationLimit = 10;
        useOSProber = false;
        extraEntries = ''
          menuentry "Windows" {
            insmod part_gpt
            insmod fat
            insmod chain
            search --no-floppy --fs-uuid --set=root 0624-17EE
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
        '';
      };
      boot.kernelModules = [ "atlantic" ];
      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

      # Cache for the CachyOS kernel selected above, avoiding local builds
      # when a substitute is available.
      nix.settings = {
        substituters = [ "https://attic.xuyh0120.win/lantian" ];
        trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
      };

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
          # Personal volume: only the owning user can access its contents.
          "umask=077"
          "nofail"
        ];
      };
    };
  };
}

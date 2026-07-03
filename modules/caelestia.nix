{ pkgs, lib, config, ... }:

let
  cfg = config.modules.caelestia;
in
{
  options.modules.caelestia = {
    enable = lib.mkEnableOption "Caelestia shell (bar, launcher, lock, notifications, wallpaper)";

    lockBeforeSleep = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Verrouiller l'écran avant la mise en veille";
    };

    roundingScale = lib.mkOption {
      type = lib.types.float;
      default = 0.6;
      description = "Facteur d'arrondi des coins (0.0 = carré, 1.0 = maximum)";
    };

    desktopClock = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Afficher l'horloge sur le bureau";
    };

    idleTimeouts = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          timeout = lib.mkOption { type = lib.types.int; };
          idleAction = lib.mkOption { type = lib.types.str; };
          returnAction = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
        };
      });
      default = [
        { timeout = 300; idleAction = "lock"; returnAction = null; }
        { timeout = 600; idleAction = "dpms off"; returnAction = "dpms on"; }
      ];
      description = "Liste des timeouts d'inactivité avec actions associées";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (user:
      { config, ... }:
      {
        programs.caelestia = {
          enable = true;
          systemd.enable = true;
          cli.enable = true;
          settings = {
            general.idle.lockBeforeSleep = cfg.lockBeforeSleep;
            general.idle.timeouts = map
              (t: { timeout = t.timeout; idleAction = t.idleAction; }
                // lib.optionalAttrs (t.returnAction != null) { returnAction = t.returnAction; })
              cfg.idleTimeouts;
            appearance.rounding.scale = cfg.roundingScale;
            background.desktopClock.enabled = cfg.desktopClock;
            session.commands.logout   = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Logging out..."];
            session.commands.shutdown = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Shutting down..." "-p" "poweroff"];
            session.commands.reboot   = ["systemd-run" "--user" "--scope" "hyprshutdown" "-t" "Restarting..."   "-p" "reboot"];
          };
        };

        systemd.user.services.lock-on-start = {
          Unit = {
            Description = "Lock session on startup and resume via caelestia";
            After = [ "graphical-session.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
            ExecStart = "${config.programs.caelestia.cli.package}/bin/caelestia shell lock lock";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      }
    );
  };
}

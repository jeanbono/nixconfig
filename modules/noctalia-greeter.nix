{ inputs, lib, ... }:
{
  den.aspects.noctalia-greeter.nixos = { host, config, ... }:
    let
      # Every user declared on this host (host.users.<name> = {...} in
      # hosts.nix), not just furnace/pierre -- keeps this aspect reusable
      # as-is for a future host with a different (or several) users.
      hostUsernames = builtins.attrNames host.users;
    in
    {
      imports = [ inputs.noctalia-greeter.nixosModules.default ];

      services.displayManager.noctalia-greeter = {
        enable = true;
        # Lets every user on this host trigger Noctalia's "Sync Now" (or
        # "Auto-Sync Greeter") without a password, pushing the desktop's
        # live theme/wallpaper into sync.toml. greeter.toml only sets
        # scheme = "Synced" and leaves [appearance] empty, since a
        # complete palette here would always beat the synced one.
        passwordless-sync-users = hostUsernames;
        settings = {
          session.default = "Hyprland (uwsm-managed)";
          # Matches locale.nix's hardcoded "fr" (no per-host keyboard
          # layout data exists yet).
          keyboard.layout = "fr";
          appearance.scheme = "Synced";
        } // lib.optionalAttrs (host.hyprland.defaultMonitor != null) {
          # Pins the greeter to the host's default monitor. No "mirror but
          # start the cursor here" option exists: output.name disables
          # every other connector entirely.
          output.name = host.hyprland.defaultMonitor;
        };
      };

      # The greeter runs as its own "greeter" user; it reads the login
      # avatar from $HOME/.face directly (not over D-Bus), and home
      # directories are 700, so it needs execute-only traversal (not
      # read/list) into each user's home. One rule per host user, using
      # their actual configured home path rather than assuming
      # /home/<name>.
      #
      # "a" (replace), not "a+" (append): appending merges into whatever
      # ACL already exists on disk without recomputing its mask, which
      # silently neutralizes the grant on the second and later boots
      # (ext4 persists the ACL). "a" always recomputes the mask.
      systemd.tmpfiles.rules = map
        (name: "a ${config.users.users.${name}.home} - - - - user:greeter:x")
        hostUsernames;
    };
}

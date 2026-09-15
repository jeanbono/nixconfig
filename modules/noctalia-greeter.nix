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
        # Lets every user declared on this host trigger Noctalia's "Sync
        # Now" (or enable "Auto-Sync Greeter") without a password, pushing
        # the desktop's live wallpaper/palette/font/output config into
        # sync.toml. greeter.toml only sets scheme = "Synced" here and
        # leaves [appearance] otherwise empty, so sync.toml's pushed
        # palette is what actually gets used (a complete palette in
        # greeter.toml would always win over it, making sync pointless).
        # Until the first sync from inside the desktop session, the
        # greeter falls back to its "Noctalia" builtin look.
        passwordless-sync-users = hostUsernames;
        settings = {
          session.default = "Hyprland (uwsm-managed)";
          # Matches locale.nix's own hardcoded "fr" (no per-host keyboard
          # layout data exists yet) -- not host-specific data, just this
          # aspect following the same repo-wide assumption.
          keyboard.layout = "fr";
          appearance.scheme = "Synced";
        } // lib.optionalAttrs (host.hyprland.defaultMonitor != null) {
          # Pins the greeter to the host's default monitor (reusing
          # host.hyprland.defaultMonitor rather than duplicating the name
          # here). There's no "mirror but start the cursor here" option:
          # setting output.name disables every other connector entirely
          # (choose_outputs() in noctalia_compositor.c), it isn't just an
          # initial-focus hint.
          output.name = host.hyprland.defaultMonitor;
        };
      };

      # The greeter runs as its own "greeter" user; it reads the profile
      # picture via AccountsService, which (per accountsservice's
      # user_reset_icon_file()) resolves to $HOME/.face. Home directories
      # are 700, so without this the greeter can't even traverse into
      # them to read that file (confirmed: it stats the path directly, no
      # D-Bus byte transfer -- accounts_icon.cpp's iconPathReadable()).
      # Grants execute-only traversal, not read/list, so directory
      # contents stay hidden from the greeter user. One rule per host
      # user, reading each one's actual configured home path rather than
      # assuming /home/<name>.
      #
      # Use "a" (replace) rather than "a+" (append/merge with whatever ACL
      # already exists on disk): per systemd's own tmpfiles.c
      # (parse_acls_from_arg: `want_mask = !item->append_or_force`), "a+"
      # explicitly skips automatic mask recalculation, on the assumption a
      # correct mask is already in place to merge with. That's fine the
      # very first time (no ACL exists yet), but once one exists (e.g.
      # after the first boot with this rule, since ext4 persists it),
      # re-running "a+" at every subsequent boot merges into that ACL
      # without recomputing the mask -- confirmed via getfacl after a
      # reboot: "user:greeter:--x #effective:---" with mask::---, silently
      # neutralizing the grant. "a" always recomputes the mask.
      systemd.tmpfiles.rules = map
        (name: "a ${config.users.users.${name}.home} - - - - user:greeter:x")
        hostUsernames;
    };
}

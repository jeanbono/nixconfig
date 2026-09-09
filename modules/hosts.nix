{
  den.hosts.x86_64-linux.furnace = {
    # Consumed by hyprland.nix via its `{ host, ... }:` context arg — keeps
    # that aspect reusable on a host with a different screen/GPU setup
    # instead of hardcoding this machine's monitors in the feature file.
    hyprland = {
      monitors = [
        { output = "DP-3"; mode = "2560x1440@165"; position = "0x0"; scale = 1; bitdepth = 10; cm = "hdr"; sdrbrightness = 2.3; }
        { output = "DP-1"; mode = "2560x1440@300"; position = "2560x0"; scale = 1; bitdepth = 10; cm = "hdr"; sdrbrightness = 2.3; }
      ];
      workspaceRules = [
        { workspace = "1"; monitor = "DP-1"; default = true; }
        { workspace = "2"; monitor = "DP-1"; }
        { workspace = "3"; monitor = "DP-1"; }
        { workspace = "4"; monitor = "DP-1"; }
        { workspace = "5"; monitor = "DP-1"; }
        { workspace = "6"; monitor = "DP-3"; }
        { workspace = "7"; monitor = "DP-3"; }
        { workspace = "8"; monitor = "DP-3"; }
        { workspace = "9"; monitor = "DP-3"; }
        { workspace = "10"; monitor = "DP-3"; }
      ];
      defaultMonitor = "DP-1";
      nvidia = true;
      greetdUser = "pierre";
    };

    users.pierre = {
      # Consumed by git.nix/jujutsu.nix via their `{ user, ... }:` context
      # arg — single source of truth instead of duplicating the same
      # name/email/key literal in both aspect files.
      fullName = "Pierre Fraisse";
      email = "pierre.fraisse@nebulous.fr";
      signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKg9gmxgKvtgr3+UTVn5n/32QqW+8c+ueRxyN3hqKVWs";
    };
  };
}

let
  # Shared identity for every host declaring users.pierre = pierre.
  pierre = {
    fullName = "Pierre Fraisse";
    email = "pierre.fraisse@nebulous.fr";
    signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKg9gmxgKvtgr3+UTVn5n/32QqW+8c+ueRxyN3hqKVWs";
    # Proton Pass's own identity/vault label, not assumed to match fullName
    # or the Unix username.
    protonPassIdentity = "Pierre";
  };
in
{
  den.hosts.x86_64-linux.furnace = {
    lmstudio = {
      interface = "enp7s0";
      subnet = "192.168.1.0/24";
    };

    # Host-specific display settings consumed by the Hyprland aspect.
    hyprland = {
      # sdrbrightness this high compensates for a known, closed "not
      # planned" Hyprland bug (hyprwm/Hyprland#16220): sdrbrightness is
      # applied after PQ encoding instead of before it in linear light,
      # so it's not a real calibration value and may need retuning across
      # Hyprland versions.
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
      # A desktop, not a laptop: no lid, and the suspend key on this
      # keyboard is easy to hit by accident. A laptop host should leave
      # this unset and get systemd-logind's own suspend-on-lid-close default.
      logindOverrides = {
        HandleSuspendKey = "ignore";
        HandleSuspendKeyLongPress = "ignore";
        HandleLidSwitch = "ignore";
      };
    };


    users.pierre = pierre;
  };
}

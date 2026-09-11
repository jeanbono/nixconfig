{ den, ... }:
{
  den.aspects.pierre = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")

      den.aspects.agents
      den.aspects.herdr
      den.aspects.tools
      den.aspects.messaging
      den.aspects.git
      den.aspects.jujutsu
      den.aspects.ssh

      den.aspects.lmstudio
      den.aspects.intellij
      den.aspects.printing
      den.aspects.razer

      den.aspects.brave
      den.aspects.protonpass

      den.aspects.theme
      den.aspects.ghostty
      den.aspects.nvim

      den.aspects.hyprland
      den.aspects.caelestia
      den.aspects.zsh

      den.aspects.plex
    ];

    user = { ... }: {
      description = "pierre";
      extraGroups = [ "video" "audio" "input" ];
      # Pinned rather than left to NixOS's implicit first-normal-user
      # allocation, so furnace.nix's /mnt/data mount can reference it
      # instead of hardcoding uid=1000.
      uid = 1000;
    };
  };
}

{ den, ... }:
{
  den.aspects.pierre = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")

      den.aspects.claude-code
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
      den.aspects.alacritty
      den.aspects.nvim

      den.aspects.hyprland
      den.aspects.caelestia
      den.aspects.zsh

      den.aspects.plex
    ];

    user = { ... }: {
      description = "pierre";
      extraGroups = [ "video" "audio" "input" ];
    };
  };
}

{ config, pkgs, lib, hostName, ... }:

let
  onePassPath = "~/.1password/agent.sock";
in {
  imports = [
    ../../modules/home
  ];

  # --- Modules home composables ---
  modules.home = {
    core.enable = true;
    zsh.enable = true;
    kitty.enable = true;
    plasma.enable = true;
  };

  home.username = "pierre";
  home.homeDirectory = "/home/pierre";
  home.stateVersion = "25.05";

  programs = {
    home-manager.enable = true;
    discord.enable = true;
    brave.enable = true;
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        identityAgent = onePassPath;
      };
    };
    jujutsu = {
      enable = true;
      settings = {
        user = {
          email = "pierre.fraisse@nebulous.fr";
          name = "Pierre Fraisse";
        };
      };
    };
  };

  home.packages = with pkgs; [
    zulip
    element-desktop
  ];
}

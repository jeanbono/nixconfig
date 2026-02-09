{ config, pkgs, lib, hostName, ... }:

let
  onePassPath = "~/.1password/agent.sock";
in {
  imports = [
    ../../modules/home/core.nix
    ../../modules/home/zsh.nix
    ../../modules/home/kitty.nix
    ../../modules/home/plasma.nix
  ];

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

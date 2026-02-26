{ pkgs, lib, config, ... }:

let
  cfg = config.modules.home.git;
in
{
  options.modules.home.git.enable = lib.mkEnableOption "Git + Jujutsu";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      git
    ];

    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          email = "pierre.fraisse@nebulous.fr";
          name = "Pierre Fraisse";
        };
        revset-aliases = {
          "closest_pushable(to)" = ''heads(::to & mutable() & ~description(exact:"") & (~empty() | merges()))'';
        };
        aliases = {
          tug = ["bookmark" "move" "--from" "heads(::@ & bookmarks())" "--to" "closest_pushable(@)"];
        };
      };
    };
  };
}

{ lib, config, ... }:

let
  cfg = config.modules.jujutsu;
in
{
  options.modules.jujutsu.enable = lib.mkEnableOption "Jujutsu (VCS)";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.modules.users (_: {
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
            tug = [ "bookmark" "move" "--from" "heads(::@ & bookmarks())" "--to" "closest_pushable(@)" ];
          };
        };
      };
    });
  };
}

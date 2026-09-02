let
  userName = "Pierre Fraisse";
  userEmail = "pierre.fraisse@nebulous.fr";
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKg9gmxgKvtgr3+UTVn5n/32QqW+8c+ueRxyN3hqKVWs";
in
{
  den.aspects.jujutsu.homeManager = { pkgs, config, ... }: {
    home.file.".ssh/allowed-signers".text = "${userEmail} ${signingKey}\n";

    # less (pager par défaut de `jj log`) affiche "<U+XXXX>" pour les glyphes
    # Nerd Font (zone Private Use Area) qu'il ne reconnaît pas comme imprimables.
    home.sessionVariables.LESSUTFCHARDEF = "e000-f8ff:p";

    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          email = userEmail;
          name = userName;
        };
        signing = {
          backend = "ssh";
          behavior = "own";
          key = signingKey;
          backends.ssh.program = "${pkgs.openssh}/bin/ssh-keygen";
          backends.ssh.allowed-signers = "${config.home.homeDirectory}/.ssh/allowed-signers";
        };
        revset-aliases = {
          "closest_pushable(to)" = ''heads(::to & mutable() & ~description(exact:"") & (~empty() | merges()))'';
        };
        aliases = {
          tug = [ "bookmark" "move" "--from" "heads(::@ & bookmarks())" "--to" "closest_pushable(@)" ];
        };
        ui.show-cryptographic-signatures = true;
        template-aliases."format_short_cryptographic_signature(sig)" = ''
          if(sig,
            label("signature status " ++ sig.status(),
              if(sig.status() == "good", "",
              if(sig.status() == "bad", "",
              if(sig.status() == "unknown", "",
              "")))
            ),
            label("signature status invalid", "(no sig)"),
          )
        '';
      };
    };
  };
}

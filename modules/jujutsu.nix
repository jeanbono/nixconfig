let
  userName = "Pierre Fraisse";
  userEmail = "pierre.fraisse@nebulous.fr";
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKg9gmxgKvtgr3+UTVn5n/32QqW+8c+ueRxyN3hqKVWs";
in
{
  den.aspects.jujutsu.homeManager = { pkgs, config, ... }: {
    home.file.".ssh/allowed-signers".text = "${userEmail} ${signingKey}\n";

    # less (the default pager for `jj log`) displays "<U+XXXX>" for Nerd Font
    # glyphs (Private Use Area) it doesn't recognize as printable.
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
        # Makes the native `jj bookmark advance` (alias `jj b a`) target the last
        # described/non-empty ancestor instead of `@`, which is often a fresh
        # empty commit — same effect as the old `tug` alias, without needing one.
        revsets."bookmark-advance-to" = "closest_pushable(@)";
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

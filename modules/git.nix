{
  den.aspects.git.homeManager = { pkgs, lib, user, ... }:
    let
      gitlabHost = "gitlab.nebulous.fr";
    in
    {
      home.packages = [ pkgs.glab ];
      # glab can't write its credential helper into the read-only git config.
      # It resolves the token from GLAB_CONFIG_DIR, so each glab identity
      # authenticates HTTPS with its own token.
      programs.git.settings.credential."https://${gitlabHost}".helper = "!${lib.getExe pkgs.glab} auth git-credential";
      programs.ssh.settings.${gitlabHost}.port = 2222;

      programs.git = {
        enable = true;
        settings.user = {
          name = user.fullName;
          email = user.email;
        };
        signing = {
          key = user.signingKey;
          format = "ssh";
          signByDefault = true;
          # Self-contained: writes its own allowed_signers (under
          # $XDG_CONFIG_HOME/git/) and points gpg.ssh.allowedSignersFile at
          # it automatically — no dependency on den.aspects.jujutsu.
          allowedSigners = "${user.email} ${user.signingKey}";
        };
      };
    };
}

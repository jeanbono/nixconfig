{
  den.aspects.git.homeManager = { user, ... }: {
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

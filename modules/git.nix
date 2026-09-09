{
  den.aspects.git.homeManager = { user, config, ... }: {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = user.fullName;
          email = user.email;
        };
        # File created by den.aspects.jujutsu, not here.
        gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed-signers";
      };
      signing = {
        key = user.signingKey;
        format = "ssh";
        signByDefault = true;
      };
    };
  };
}

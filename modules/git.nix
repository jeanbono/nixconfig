{
  den.aspects.git.homeManager = { config, ... }: {
    programs.git = {
      enable = true;
      settings.gpg = {
        format = "ssh";
        # File created by den.aspects.jujutsu (home.file), not here.
        ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed-signers";
      };
    };
  };
}

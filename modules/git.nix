{
  den.aspects.git.homeManager = { config, ... }: {
    programs.git = {
      enable = true;
      settings.gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed-signers";
      };
    };
  };
}

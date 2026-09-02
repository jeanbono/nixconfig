{
  den.aspects.git.homeManager = { config, ... }: {
    programs.git = {
      enable = true;
      settings.gpg = {
        format = "ssh";
        # Fichier créé par den.aspects.jujutsu (home.file), pas ici.
        ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed-signers";
      };
    };
  };
}

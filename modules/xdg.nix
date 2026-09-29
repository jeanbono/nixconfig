{
  den.aspects.xdg.homeManager = { config, ... }: {
    # English names regardless of the French locale: tools (yazi icons,
    # scripts) only recognize the standard ones.
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = false;
      # A name yazi's folder icons recognize, unlike the default "Projects".
      projects = "${config.home.homeDirectory}/Development";
    };
    # Replaces the file xdg-user-dirs-update generated from the locale.
    xdg.configFile."user-dirs.dirs".force = true;
  };
}

{
  den.aspects.yazi.homeManager = { ... }: {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
      settings = {
        mgr = {
          show_hidden = false;
          sort_by = "natural";
          sort_dir_first = true;
        };
      };
    };
  };
}

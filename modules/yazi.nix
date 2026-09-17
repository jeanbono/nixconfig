{ inputs, ... }:
{
  den.aspects.yazi.homeManager = { pkgs, ... }: {
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
      theme.flavor = {
        dark = inputs.self.lib.theme.flavor;
        light = inputs.self.lib.theme.flavor;
      };
      flavors.${inputs.self.lib.theme.flavor} =
        let
          flavor = inputs.self.lib.theme.flavor;
          themeSource = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "yazi";
            rev = "fc69d6472d29b823c4980d23186c9c120a0ad32c";
            sha256 = "sha256-Og33IGS9pTim6LEH33CO102wpGnPomiperFbqfgrJjw=";
          };
          syntaxTheme = pkgs.catppuccin.override {
            variant = flavor;
            themeList = [ "bat" ];
          };
        in
        pkgs.runCommand "catppuccin-${flavor}-yazi" { } ''
          mkdir -p "$out"
          # Package the upstream theme as a flavor with its own syntax theme.
          # The standalone theme's home-relative syntect path is not needed.
          sed '/^syntect_theme = /d' \
            ${themeSource}/themes/${flavor}/catppuccin-${flavor}-mauve.toml \
            > "$out/flavor.toml"
          cp ${syntaxTheme}/bat/*.tmTheme "$out/tmtheme.xml"
          cp ${themeSource}/LICENSE "$out/LICENSE"
        '';
    };
  };
}

{
  den.aspects.herdr.homeManager = { pkgs, ... }: {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "herdr-with-session-hooks";
        paths = [ pkgs.herdr ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        # Official Claude/Codex hooks need python3 to report session IDs.
        # The server and its child panes inherit this PATH.
        postBuild = ''
          wrapProgram $out/bin/herdr \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.python3 ]}
        '';
      })
    ];
  };
}

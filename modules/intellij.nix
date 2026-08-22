{
  den.aspects.intellij = {
    nixos = { ... }: {
      programs.java.enable = true;
    };
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [ jetbrains.idea ];
    };
  };
}

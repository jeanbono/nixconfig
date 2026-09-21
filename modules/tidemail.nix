{ inputs, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.tidemail = pkgs.callPackage ./_packages/tidemail.nix { };
  };

  den.aspects.tidemail.homeManager = { pkgs, ... }: {
    home.packages = [ inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.tidemail ];
  };
}

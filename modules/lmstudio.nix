{
  den.aspects.lmstudio = {
    nixos = { host, lib, ... }: {
      # Only the host's IPv4 LAN can reach the API; no global port opening.
      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -i ${lib.escapeShellArg host.lmstudio.interface} -s ${lib.escapeShellArg host.lmstudio.subnet} -p tcp --dport 1234 -j nixos-fw-accept
      '';
    };
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.lmstudio ];
    };
  };
}

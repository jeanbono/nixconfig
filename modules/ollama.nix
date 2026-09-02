{
  den.aspects.ollama.nixos = { pkgs, ... }: {
    # Workaround nixpkgs#545286 : cmake 4.3+ refuse CUDAToolkit_ROOT si bin/nvcc
    # est absent — le hook nixpkgs le remplit mal. Unset force cmake à trouver
    # nvcc via PATH (déjà présent en nativeBuildInputs). PR#545542 non mergé.
    nixpkgs.overlays = [
      (_: prev: {
        ollama-cuda = prev.ollama-cuda.overrideAttrs (old: {
          preBuild = "unset CUDAToolkit_ROOT\n" + (old.preBuild or "");
        });
      })
    ];

    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      host = "0.0.0.0";
      port = 11434;
      loadModels = [ "qwen3.5:9b" ];
    };

    systemd.services.ollama.serviceConfig.ExecStartPre =
      # Attend /dev/nvidia0 jusqu'à 30s avant de démarrer ; ignore l'échec si absent
      "-${pkgs.bash}/bin/bash -c 'i=0; while [ $i -lt 30 ] && [ ! -e /dev/nvidia0 ]; do sleep 1; i=$((i+1)); done'";

    networking.firewall.allowedTCPPorts = [ 11434 ];
  };
}

{
  den.aspects.ollama.nixos = { pkgs, ... }: {
    # Workaround for nixpkgs#545286: cmake 4.3+ rejects CUDAToolkit_ROOT when
    # bin/nvcc is missing — the nixpkgs hook fills it in incorrectly. Unsetting
    # it forces cmake to find nvcc via PATH (already in nativeBuildInputs).
    # PR#545542 not merged.
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
      # Waits up to 30s for /dev/nvidia0 before starting; ignores failure if absent
      "-${pkgs.bash}/bin/bash -c 'i=0; while [ $i -lt 30 ] && [ ! -e /dev/nvidia0 ]; do sleep 1; i=$((i+1)); done'";

    networking.firewall.allowedTCPPorts = [ 11434 ];
  };
}

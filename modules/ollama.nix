{ pkgs, lib, config, ... }:

let cfg = config.modules.ollama; in
{
  options.modules.ollama = {
    enable = lib.mkEnableOption "Ollama (LLM local)";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Ouvre le port 11434 dans le pare-feu";
    };
  };

  config = lib.mkIf cfg.enable {
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

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 11434 ];
  };
}

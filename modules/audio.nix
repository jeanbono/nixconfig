{ lib, config, ... }:

let
  cfg = config.modules.audio;
in
{
  options.modules.audio.enable = lib.mkEnableOption "PipeWire (ALSA, PulseAudio, JACK)";

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}

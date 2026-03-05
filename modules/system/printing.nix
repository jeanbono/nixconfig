{ pkgs, lib, config, ... }:

let
  cfg = config.modules.system.printing;
  printerName = "Brother_DCP_1610W";
  printerHost = "brwf0a654d3138e.lan";
in
{
  options.modules.system.printing.enable =
    lib.mkEnableOption "Impression (CUPS)";

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser
      ];
    };

    hardware.printers = {
      ensureDefaultPrinter = printerName;
      ensurePrinters = [
        {
          name = printerName;
          description = "Brother DCP-1610W";
          location = "Bureau";
          deviceUri = "socket://${printerHost}";
          model = "drv:///brlaser.drv/br1610.ppd";
          ppdOptions = {
            PageSize = "A4";
          };
        }
      ];
    };
  };
}

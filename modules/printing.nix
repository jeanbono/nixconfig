{ pkgs, lib, config, ... }:

let
  cfg = config.modules.printing;
  printerName = "Brother_DCP_1610W";
  printerHost = "brwf0a654d3138e.lan";
in
{
  options.modules.printing.enable = lib.mkEnableOption "Impression + scan (CUPS + SANE) — Brother DCP-1610W";

  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [ brlaser ];
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
          ppdOptions = { PageSize = "A4"; };
        }
      ];
    };

    hardware.sane = {
      enable = true;
      brscan4 = {
        enable = true;
        netDevices = {
          brother = {
            model = "DCP-1610W";
            nodename = printerHost;
          };
        };
      };
    };

    home-manager.users = lib.genAttrs config.modules.users (_: {
      home.packages = with pkgs; [
        simple-scan
      ];
    });
  };
}

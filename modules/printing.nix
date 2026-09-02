let
  printerName = "Brother_DCP_1610W";
  printerHost = "brwf0a654d3138e.lan";
in
{
  den.aspects.printing = {
    nixos = { pkgs, ... }: {
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
            location = "Office";
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
    };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        simple-scan
      ];
    };
  };
}

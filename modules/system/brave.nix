{ lib, config, ... }:

let
  cfg = config.modules.system.brave;
  ublockId = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
in
{
  options.modules.system.brave = {
    enable = lib.mkEnableOption "Brave browser policies (system-level)";

    extraExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra extensions to force-install via policy (id;update_url format)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."brave/policies/managed/00-brave.json".text = builtins.toJSON {
      BraveRewardsDisabled = true;
      BraveWalletDisabled = true;
      BraveVPNDisabled = true;
      TorDisabled = true;
      BraveAIChatEnabled = false;
      ExtensionInstallForcelist = [
        "${ublockId};https://clients2.google.com/service/update2/crx"
      ] ++ cfg.extraExtensions;
      "3rdparty" = {
        extensions = {
          ${ublockId} = {
            adminSettings = builtins.toJSON {
              advancedUserEnabled = true;
              userResourcesLocation = "https://raw.githubusercontent.com/pixeltris/TwitchAdSolutions/master/vaft/vaft-ublock-origin.js";
              userFilters = "twitch.tv##+js(twitch-videoad)";
            };
          };
        };
      };
    };
  };
}

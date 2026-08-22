let
  ublockId = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
  catppuccinMacchiatoId = "cmpdlhmnmjhihmcfnigoememnffkimlk";
in
{
  den.aspects.brave = {
    nixos = { ... }: {
      environment.etc."brave/policies/managed/00-brave.json".text = builtins.toJSON {
        BackgroundModeEnabled = false;
        BraveRewardsDisabled = true;
        BraveWalletDisabled = true;
        BraveVPNDisabled = true;
        TorDisabled = true;
        BraveAIChatEnabled = false;
        PasswordManagerEnabled = false;
        ExtensionInstallForcelist = [
          "${ublockId};https://clients2.google.com/service/update2/crx"
        ];
        ExtensionSettings = {
          ${ublockId} = {
            toolbar_pin = "force_pinned";
          };
          ${catppuccinMacchiatoId} = {
            installation_mode = "force_installed";
            update_url = "https://clients2.google.com/service/update2/crx";
          };
        };
        "3rdparty" = {
          extensions = {
            ${ublockId} = {
              userSettings = [
                [ "advancedUserEnabled" "true" ]
              ];
              advancedSettings = [
                [ "userResourcesLocation" "https://raw.githubusercontent.com/pixeltris/TwitchAdSolutions/master/vaft/vaft-ublock-origin.js" ]
              ];
              toOverwrite = {
                filters = [
                  "twitch.tv##+js(twitch-videoad)"
                ];
              };
            };
          };
        };
      };
    };

    homeManager = { ... }: {
      programs.brave.enable = true;
    };
  };
}

let
  ublockId = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
  catppuccinMacchiatoId = "cmpdlhmnmjhihmcfnigoememnffkimlk";
  # Owned here, not in protonpass.nix: Chromium's own docs say setting the
  # same managed policy (ExtensionSettings) from two separate *.json files is
  # UNDEFINED behavior, not a safe merge — verified the hard way (a prior
  # split caused every forced extension, ProtonPass included, to silently
  # stop installing). One aspect must own the whole ExtensionSettings value.
  protonPassId = "ghmbeldphafepmbegfdlkpapadhbakde";
in
{
  den.aspects.brave = {
    nixos = { ... }: {
      programs.chromium = {
        enable = true;
        extraOpts = {
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
            ${protonPassId} = {
              installation_mode = "force_installed";
              update_url = "https://clients2.google.com/service/update2/crx";
              toolbar_pin = "force_pinned";
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
    };

    homeManager = { ... }: {
      programs.brave.enable = true;
    };
  };
}

let
  # Google delisted classic uBlock Origin (cjpalhdlnbpafiamejdnhcphjbkeiagm)
  # from the Web Store with the Manifest V2 sunset. Brave keeps its own MV2
  # build alive under a different id — enable it once, manually, via
  # brave://settings/extensions/v2 ("Manifest V2 extensions" toggle); it
  # isn't force-installable through policy (not a Web Store listing, so
  # ExtensionInstallForcelist/installation_mode can't fetch it). Once enabled,
  # ExtensionSettings/3rdparty below still apply to it normally.
  ublockId = "jcokkipkhhgiakinbnnplhkdbjbgcgpe";
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
          # Native address/email/phone autofill suggestions overlap with
          # ProtonPass's own dropdown.
          AutofillAddressEnabled = false;
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

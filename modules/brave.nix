let
  # Enable Brave's bundled uBlock Origin once at brave://settings/extensions/v2.
  # It is not available through Web Store force-install policies.
  ublockId = "jcokkipkhhgiakinbnnplhkdbjbgcgpe";
  catppuccinMacchiatoId = "cmpdlhmnmjhihmcfnigoememnffkimlk";
  # Keep ExtensionSettings in one policy file: Chromium does not safely
  # merge the same managed policy across multiple files.
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
                  [ "userResourcesLocation" "https://raw.githubusercontent.com/pixeltris/TwitchAdSolutions/c51ef2fe8f667f9dc9216eb550924cf0d732ce27/vaft/vaft-ublock-origin.js" ]
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

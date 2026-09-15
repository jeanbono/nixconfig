{
  den.aspects.keyring.nixos = { ... }: {
    # Also sets security.pam.services.login.enableGnomeKeyring, which is what
    # actually unlocks the login keyring: greetd's own PAM service hardcodes
    # useDefaultRules = false and substacks/includes "login" regardless of
    # greeter frontend, so enabling it directly on "greetd" would be inert.
    services.gnome.gnome-keyring.enable = true;
  };
}

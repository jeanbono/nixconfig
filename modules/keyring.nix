{
  den.aspects.keyring.nixos = { ... }: {
    services.gnome.gnome-keyring.enable = true;
    # PAM passes the login password to the login keyring.
    security.pam.services.greetd.enableGnomeKeyring = true;
  };
}

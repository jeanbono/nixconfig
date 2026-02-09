{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    curl
    wget
    ripgrep
    fd
    jq
    unzip
  ];

  # Variables utiles Wayland / Electron (côté user)
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}

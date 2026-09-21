{ lib, stdenvNoCC, fetchurl, makeWrapper, libsecret, libnotify, wl-clipboard, xclip, xdg-utils }:

stdenvNoCC.mkDerivation rec {
  pname = "tidemail";
  version = "1.0.28";

  src = fetchurl {
    url = "https://github.com/allisonhere/tidemail/releases/download/v${version}/tidemail-linux-x86_64.tar.gz";
    hash = "sha256-1iKjtB0ID15rcuE1Em3Vq3tlSNvbLfMBwDRW1a1bTh8=";
  };
  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;
  # Preserve the upstream static binary, including its embedded build data.
  dontStrip = true;

  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall
    install -Dm755 tidemail-linux-x86_64 $out/bin/tidemail
    wrapProgram $out/bin/tidemail \
      --prefix PATH : ${lib.makeBinPath [ libsecret libnotify wl-clipboard xclip xdg-utils ]}
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    test "$($out/bin/tidemail --version)" = "tidemail v${version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "Terminal email client with IMAP and SMTP support";
    homepage = "https://github.com/allisonhere/tidemail";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "tidemail";
    platforms = [ "x86_64-linux" ];
  };
}

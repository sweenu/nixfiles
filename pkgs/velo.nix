{
  appimageTools,
  fetchurl,
  lib,
}:

let
  pname = "velo";
  version = "0.4.21";
  src = fetchurl {
    url = "https://github.com/avihaymenahem/velo/releases/download/velo-v${version}/Velo_${version}_amd64.AppImage";
    hash = "sha256-T55mgJ6AVfHAcU8m5yIBf+8XXoKrIMV2aWwk8u3yRlg=";
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${contents}/*.desktop -t $out/share/applications
    cp -r ${contents}/usr/share/icons $out/share/
  '';

  meta = {
    description = "Open source desktop email client";
    homepage = "https://velomail.app";
    license = lib.licenses.asl20;
    mainProgram = "velo";
    platforms = [ "x86_64-linux" ];
  };
}

{ stdenv, lib, fetchurl, appimageTools, makeWrapper, electron }:

stdenv.mkDerivation rec {
  pname = "freeshow";
  version = "1.1.4";

  src = fetchurl {
    url = "https://github.com/ChurchApps/FreeShow/releases/download/v${version}/FreeShow-${version}.AppImage";
    sha256 = "sha256-LDJeoGfGisplCOHn7EnRwPvRcAaIqB4uJmCzJSh4siI=";
  };

  appimageContents = appimageTools.extractType2 {
    name = "${pname}-${version}";
    inherit src;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/${pname} $out/share/applications $out/share/icons/hicolor/scalable/apps

    cp -a ${appimageContents}/{locales,resources} $out/share/${pname}
    cp -a ${appimageContents}/freeshow.desktop $out/share/applications/${pname}.desktop
    cp -a ${appimageContents}/usr/share/icons/hicolor/scalable/freeshow.svg $out/share/icons/hicolor/scalable/apps

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/${pname}/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland}}"
  '';

  meta = with lib; {
    description = "A free and open-source, user-friendly presenter software";
    homepage = "https://freeshow.app/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ sweenu ];
    inherit (electron.meta) platforms;
    # mainProgram = "freeshow";
  };
}

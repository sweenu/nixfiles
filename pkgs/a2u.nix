{ fetchurl
, lib
, stdenv
, squashfsTools
, xorg
, alsa-lib
, makeWrapper
, wrapGAppsHook
, openssl
, freetype
, glib
, pango
, cairo
, atk
, gdk-pixbuf
, gtk3
, cups
, nspr
, nss
, libpng
, libnotify
, libgcrypt
, systemd
, fontconfig
, dbus
, expat
, ffmpeg
, curlWithGnuTls
, zlib
, gnome
, at-spi2-atk
, at-spi2-core
, libpulseaudio
, libdrm
, mesa
, libxkbcommon
}:

let
  # TO UPDATE: just execute the ./update.sh script (won't do anything if there is no update)
  # "rev" decides what is actually being downloaded
  # If an update breaks things, one of those might have valuable info:
  # https://aur.archlinux.org/packages/spotify/
  # https://community.spotify.com/t5/Desktop-Linux
  version = "6.0.23";
  # To get the latest stable revision:
  # curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/spotify?channel=stable' | jq '.download_url,.version,.last_updated'
  # To get general information:
  # curl -H 'Snap-Device-Series: 16' 'https://api.snapcraft.io/v2/snaps/info/spotify' | jq '.'
  # More examples of api usage:
  # https://github.com/canonical-websites/snapcraft.io/blob/master/webapp/publisher/snaps/views.py
  rev = "136";

  deps = [
    at-spi2-atk
    at-spi2-core
  ];

in

stdenv.mkDerivation {
  pname = "a2u";
  inherit version;

  # fetch from snapcraft instead of the debian repository most repos fetch from.
  # That is a bit more cumbersome. But the debian repository only keeps the last
  # two versions, while snapcraft should provide versions indefinately:
  # https://forum.snapcraft.io/t/how-can-a-developer-remove-her-his-app-from-snap-store/512

  # This is the next-best thing, since we're not allowed to re-distribute
  # spotify ourselves:
  # https://community.spotify.com/t5/Desktop-Linux/Redistribute-Spotify-on-Linux-Distributions/td-p/1695334
  src = fetchurl {
    url = "https://api.snapcraft.io/api/v1/snaps/download/Txd4fSAYd0SvOeyBrTLs2DxMGBwmIbjE_${rev}.snap";
    sha512 = "2a8d454a11907e1cc05090e54744a35aeb316e85b13e5482c5ae8fec72f46bea79148eeca89663d6fbf0f284d6f11a96";
  };

  nativeBuildInputs = [ makeWrapper squashfsTools ];

  dontStrip = true;
  dontPatchELF = true;

  unpackPhase = ''
    runHook preUnpack
    unsquashfs "$src" '/meta/snap.yaml'
    cd squashfs-root
    if ! grep -q 'grade: stable' meta/snap.yaml; then
      # Unfortunately this check is not reliable: At the moment (2018-07-26) the
      # latest version in the "edge" channel is also marked as stable.
      echo "The snap package is marked as unstable:"
      grep 'grade: ' meta/snap.yaml
      echo "You probably chose the wrong revision."
      exit 1
    fi
    if ! grep -q '${version}' meta/snap.yaml; then
      echo "Package version differs from version found in snap metadata:"
      grep 'version: ' meta/snap.yaml
      echo "While the nix package specifies: ${version}."
      echo "You probably chose the wrong revision or forgot to update the nix version."
      exit 1
    fi
    runHook postUnpack
  '';

  installPhase =
    ''
      runHook preInstall

      libdir=$out/lib/a2u
      mkdir -p $libdir
      mv ./usr/* $out/
      cp ./logic.py ./processes.py ./common.py ./a2u{css,fonts,images}.py pyatspimonitoring.py ./accountable2you.py meta/snap.yaml $out/

      rpath="$libdir"

      patchelf \
        --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath $rpath

      librarypath="${lib.makeLibraryPath deps}:$libdir"

      # Desktop file
      mkdir -p "$out/share/applications/"
      cp "$out/share/applications/accountable2you.desktop" "$out/share/applications/"

      # Icons
      # for i in 16 22 24 32 48 64 128 256 512; do
        # ixi="$i"x"$i"
        # mkdir -p "$out/share/icons/hicolor/$ixi/apps"
        # ln -s "$out/share/spotify/icons/spotify-linux-$i.png" \
          # "$out/share/icons/hicolor/$ixi/apps/spotify-client.png"
      # done

      runHook postInstall
    '';

  meta = with lib; {
    homepage = "https://accountable2you.com";
    description = "Accountability monitoring software";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ sweenu ];
    platforms = [ "x86_64-linux" ];
  };
}

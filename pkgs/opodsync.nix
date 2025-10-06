{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "opodsync";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "kd2org";
    repo = "opodsync";
    rev = "${version}";
    hash = "sha256-e31yUa+xrtSnOgLYox/83KZSH2Dj0qxqlwKvBpro/2w=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
        runHook preInstall

        mkdir -p $out/share/opodsync
        cp -r server/* $out/share/opodsync/

        # Create a wrapper script that sets up proper permissions and data directory
        mkdir -p $out/bin
        cat > $out/bin/opodsync-setup <<EOF
    #!/bin/sh
    OPODSYNC_ROOT="\''${OPODSYNC_ROOT:-/var/lib/opodsync}"
    mkdir -p "\$OPODSYNC_ROOT/data"
    chmod 755 "\$OPODSYNC_ROOT"
    chmod 755 "\$OPODSYNC_ROOT/data"
    echo "oPodSync data directory created at \$OPODSYNC_ROOT"
    echo "Web root is at $out/share/opodsync"
    EOF
        chmod +x $out/bin/opodsync-setup

        runHook postInstall
  '';

  meta = with lib; {
    description = "A minimalist GPodder-compatible server for self-hosting podcast synchronization";
    homepage = "https://github.com/kd2org/opodsync";
    license = licenses.agpl3Only;
    maintainers = [ sweenu ];
    platforms = platforms.all;
  };
}

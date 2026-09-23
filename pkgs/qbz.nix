# qbz was removed from nixpkgs (PR #564650) because upstream deleted the
# repository; there is no replacement and no official Qobuz client for Linux.
# This is the last nixpkgs derivation (pkgs/by-name/qb/qbz, rev 4f0439e2),
# carried forward to 2.1.2 and taught to build the Qt frontend. `src` comes
# from the qbz-src flake input rather than fetchFromGitHub, since our fork is
# private and git+ssh authenticates where fetchFromGitHub would need a netrc.
#
# The pinned revision is verified authentic, not merely plausible: its tree
# hashes to sha256-GvXEbUmmgXaCxsA1VvmQXzq3CrEU0ojfG2LQDWhueZY=, the hash
# nixpkgs recorded for v2.1.2 in PR #561161 before upstream disappeared. (That
# PR only bumped version/hashes and was closed unbuilt, so it is not evidence
# that any of the Qt wiring below is unnecessary.)
#
# 2.1.x replaced the Slint UI with Qt/QML via cxx-qt, which is why this needs
# far more than the old derivation did. The awkward part is qtMerged/qmake
# below; see the comment there.
{
  alsa-lib,
  autoPatchelfHook,
  cmake,
  lib,
  libglvnd,
  libjack2,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  nasm,
  pipewire, # pw-metadata/pw-dump for bit-perfect sample rate queries and DAC detection
  pkg-config,
  pulseaudio, # pactl for PipeWire device enumeration and sink routing
  qt6,
  rustPlatform,
  src,
  symlinkJoin,
  vulkan-loader,
  wayland,
  writeShellScriptBin,
  xdg-utils,
}:

let
  qtModules = with qt6; [
    qtbase
    qtdeclarative # Qml, Quick, QuickControls2 + qmltyperegistrar/qmlcachegen
    qtshadertools
    qtsvg
    qtwayland
  ];

  qtMerged = symlinkJoin {
    name = "qbz-qt6-merged";
    paths = qtModules;
  };

  # cxx-qt finds its host tools purely through `qmake -query` — qt-build-utils
  # 0.7.3 probes QT_HOST_LIBEXECS, QT_HOST_BINS, QT_INSTALL_LIBEXECS and
  # QT_INSTALL_BINS in turn and never falls back to PATH. nixpkgs splits Qt
  # across one store path per module, so qmake reports qtbase's libexec, which
  # holds moc and rcc but not qmltyperegistrar or qmlcachegen (qtdeclarative)
  # — the build then dies with "Could not find qmltyperegistrar". This is why
  # upstream's own flake gave up on source builds and ships prebuilt tarballs
  # (their issue #744).
  #
  # Pointing qmake at qtMerged via a symlink does not work: Qt resolves
  # /proc/self/exe to the real qtbase path and answers from there, so a qt.conf
  # beside the symlink is never read. Rewrite the answers instead. The same
  # substitution also redirects QT_INSTALL_HEADERS and QT_INSTALL_LIBS at the
  # merged tree, which is what makes the QtQml/QtQuick headers resolvable.
  qmakeWrapper = writeShellScriptBin "qmake" ''
    if [ "$1" = "-query" ]; then
      ${qt6.qtbase}/bin/qmake "$@" | sed "s|${qt6.qtbase}|${qtMerged}|g"
    else
      exec ${qt6.qtbase}/bin/qmake "$@"
    fi
  '';
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "qbz";
  version = "2.1.2";

  inherit src;

  cargoHash = "sha256-7128HdosQ7qWSXAMj0BYzePMdHM7BV3pfzj3s563tF8=";
  cargoRoot = "crates";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  # The workspace also builds qbzd and assorted helpers; we only want the app.
  cargoBuildFlags = [
    "-p"
    "qbz-qt"
    "--bin"
    "qbz"
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    cmake
    nasm
    pkg-config
    qmakeWrapper
    qt6.wrapQtAppsHook
  ];

  # cmake is here only because a -sys crate shells out to it; this project has
  # no CMakeLists of its own, so the setup hook must not try to configure one.
  dontUseCmakeConfigure = true;

  buildInputs = qtModules ++ [
    alsa-lib
    libjack2
  ];

  runtimeDependencies = [
    libglvnd
    libxkbcommon
    libx11
    libxcursor
    libxi
    vulkan-loader
    wayland
  ];

  # 21 baked .qsb files are committed; without this build.rs looks for qsb to
  # re-bake them and merely warns when it is absent, which would make the
  # shaders depend on whether qtshadertools happened to be found.
  env.QBZ_PREBUILT_SHADERS = "1";

  # QMAKE deliberately does NOT go in `env`: qtbase's setup hook does an
  # unconditional `export QMAKE=<qtbase>/bin/qmake` ("Build tools are often
  # confused if QMAKE is unset"), and setup hooks run after the derivation
  # environment is set up, so it silently wins. Re-export once the hooks are
  # done instead.
  preBuild = ''
    export QMAKE=${qmakeWrapper}/bin/qmake
  '';

  # Engine crates are tested in upstream CI; running the test profile on top of
  # a Qt build doubles wall time for no packaging value.
  doCheck = false;

  qtWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      pipewire
      pulseaudio
      xdg-utils
    ])
  ];

  postInstall = ''
    install -Dm644 $src/packaging/linux/qbz.desktop \
      $out/share/applications/qbz.desktop
    # Ships Exec=/usr/bin/qbz, which does not exist here, so anything launching
    # through the desktop entry (app launchers, the qobuzapp:// handler) fails.
    # The absolute path is deliberate upstream — see the comment in their
    # .desktop about KWin only exposing the window-management interface to an
    # absolute Exec — so point it at the wrapper rather than dropping the path.
    substituteInPlace $out/share/applications/qbz.desktop \
      --replace-fail /usr/bin/qbz $out/bin/qbz
    for size in 32 48 64 128 256 512; do
      install -Dm644 $src/packaging/icons/"$size"x"$size".png \
        $out/share/icons/hicolor/"$size"x"$size"/apps/qbz.png
    done
  '';

  meta = {
    description = "Native, full-featured hi-fi Qobuz desktop player for Linux, with fast, bit-perfect audio playback";
    homepage = "https://qbz.lol";
    license = lib.licenses.mit;
    mainProgram = "qbz";
    platforms = lib.platforms.linux;
  };
})

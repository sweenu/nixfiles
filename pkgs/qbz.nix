# qbz was removed from nixpkgs (PR #564650) because upstream deleted the
# repository; there is no replacement and no official Qobuz client for Linux.
# This is the last nixpkgs derivation (pkgs/by-name/qb/qbz, rev 4f0439e2), with
# fetchFromGitHub swapped for a `src` passed in from the qbz-src flake input,
# since our fork is private and git+ssh handles that auth while fetchFromGitHub
# would need a netrc.
#
# The pinned revision is verified authentic, not merely plausible: its git tree
# is byte-identical to the v2.0.2 source cache.nixos.org still serves, which is
# what the nixpkgs maintainer hashed before the takedown.
#
# Stays on 2.0.2 rather than 2.1.2 because 2.1.x rewrote the UI from Slint to
# Qt/QML, which this derivation cannot build — it has no Qt inputs, and
# upstream's own flake gave up on source builds over qmltyperegistrar and
# shipped prebuilt tarballs instead. Moving to 2.1.2 means writing a Qt6
# derivation (qtbase + qtdeclarative + wrapQtAppsHook; it builds through
# crates/qbz-qt/build.rs), not bumping a version. If that is ever attempted:
#
#   rev        e537c7fd41d2bad7e39128c3bb7a5ae7effcbf8f  ("merge: QBZ 2.1.2")
#   cargoHash  sha256-7128HdosQ7qWSXAMj0BYzePMdHM7BV3pfzj3s563tF8=
#
# That revision is verified the same way: its tree hashes to
# sha256-GvXEbUmmgXaCxsA1VvmQXzq3CrEU0ojfG2LQDWhueZY=, the hash nixpkgs
# recorded for v2.1.2 in PR #561161 before upstream disappeared. Note that PR
# only ever bumped version/hashes and was closed unbuilt, so it is not evidence
# that a Qt-less derivation compiles 2.1.x.
{
  alsa-lib,
  autoPatchelfHook,
  fontconfig,
  freetype,
  lib,
  libglvnd,
  libjack2,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  makeWrapper,
  pipewire, # pw-metadata/pw-dump for bit-perfect sample rate queries and DAC detection
  pkg-config,
  pulseaudio, # pactl for PipeWire device enumeration and sink routing
  rustPlatform,
  src,
  vulkan-loader,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "qbz";
  version = "2.0.2";

  inherit src;

  cargoHash = "sha256-FPDyn61rO/hW9gEUU/yo+mXhnamwwXU1mj3wGQpHA3o=";
  cargoRoot = "crates";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
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

  # The generated Slint UI module is a single very large compilation unit;
  # running the test profile on top of the build doubles wall time and memory
  # for no packaging value. Engine crates are tested in upstream CI.
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/qbz \
      --prefix PATH : ${
        lib.makeBinPath [
          pulseaudio
          pipewire
        ]
      }

    install -Dm644 $src/packaging/linux/qbz.desktop \
      $out/share/applications/qbz.desktop
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

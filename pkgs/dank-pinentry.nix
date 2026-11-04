# The Assuan pinentry that the dankbarPinentry DMS plugin draws for. The two
# halves talk over a private unix-socket protocol (PROTOCOL.md upstream), so
# `src` and `version` come from the plugin registry's own pin rather than a
# separate fetch here — that way the binary can never drift from the QML it
# is paired with.
#
# Upstream's flake splits dank-askpass into a second output so that installing
# the pinentry does not also put an askpass on PATH. Both are kept here
# instead: the plugin's startup check probes for dank-askpass too and warns
# when it is missing.
{
  lib,
  rustPlatform,
  src,
  version,
}:

rustPlatform.buildRustPackage {
  pname = "dank-pinentry";
  inherit src version;

  cargoLock.lockFile = "${src}/Cargo.lock";

  meta = {
    description = "Pinentry with a TTY frontend and a DankMaterialShell plugin frontend";
    homepage = "https://github.com/augustocdias/dank-pinentry";
    license = lib.licenses.mit;
    mainProgram = "dank-pinentry";
    platforms = lib.platforms.linux;
  };
}

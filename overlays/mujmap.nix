# TODO: remove overlay when version 0.3 is out
final: prev: {
  mujmap = prev.mujmap.overrideAttrs (old: rec {
    src = prev.fetchFromGitHub {
      owner = "elizagamedev";
      repo = "mujmap";
      rev = "1643034e565f6a16277199be76f3ff6c4d23bd02";
      sha256 = "sha256-3vuSUUhclF1k7SRXsFnAUgno3oqgqYDfrjFMEFhsxJs=";
    };

    cargoDeps = old.cargoDeps.overrideAttrs (prev.lib.const {
      name = "0.2.0-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-4QEP7YIHDp/YCWqbuKISbXLhngUQB5pAaZ2Zq33b4uo=";
    });
  });
}

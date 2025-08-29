final: prev: {
  manix = prev.manix.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (final.fetchpatch {
        url = "https://github.com/nix-community/manix/pull/20.patch";
        sha256 = "14npcz3svdcvyxxmhcfml1v2dmkl7axmwjb1hsv3ff8x9y64fppm";
      })
    ];
  });
}

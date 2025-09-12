final: prev: {
  music-assistant = prev.music-assistant.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (prev.fetchpatch {
        url = "https://github.com/sweenu/music-assistant/commit/fa72831ed3c375a9e81baed9ac40e0d242a03c86.patch";
        hash = "sha256-GoVhhgnvzzig5gOHR7Vrs+i5oxqWHzOHPUgfBCppfWc=";
      })
    ];
  });
}

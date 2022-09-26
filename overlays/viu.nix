final: prev: {
  viu = prev.viu.overrideAttrs (old: {
    # There is not overrideRustAttrs so I can't make this work
    # buildFeatures = old.buildFeatures or [ ] ++ [ "sixel" ];
    cargoBuildFlags = old.cargoBuildFlags or [ ] ++ [ "--features=sixel" ];
    buildInputs = old.buildInputs or [ ] ++ [ prev.libsixel ];
  });
}

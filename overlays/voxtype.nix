# nixpkgs' cargo setup hook now exports LIBSQLITE3_SYS_USE_PKG_CONFIG=1, so the
# bundled sqlite is no longer built and linking fails with -lsqlite3 missing.
# Drop this once nixpkgs' voxtype lists sqlite itself.
final: prev: {
  voxtype = prev.voxtype.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ prev.sqlite ];
  });
}

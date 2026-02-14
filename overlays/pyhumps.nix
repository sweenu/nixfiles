# Until: https://github.com/NixOS/nixpkgs/issues/494075
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pfinal: pprev: {
      pyhumps = pprev.pyhumps.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (prev.fetchpatch {
            url = "https://github.com/nficano/humps/commit/f61bb34de152e0cc6904400c573bcf83cfdb67f9.patch";
            hash = "sha256-nLmRRxedpB/O4yVBMY0cqNraDUJ6j7kSBG4J8JKZrrE=";
          })
        ];
      });
    })
  ];
}

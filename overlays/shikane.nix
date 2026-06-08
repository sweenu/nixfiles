# Build shikane from Sweenu/shikane!5, which makes it read existing config
# files without requiring write permissions, so the read-only Nix store config
# works without a writable-copy workaround.
# https://gitlab.com/w0lff/shikane/-/merge_requests/5
final: prev: {
  shikane = prev.shikane.overrideAttrs (old: {
    version = "1.1.0-unstable-2026-06-08";
    src = prev.fetchFromGitLab {
      owner = "Sweenu";
      repo = "shikane";
      rev = "c520a81fae6dae1736a4484599bc18d585b18e4a";
      hash = "sha256-AKCqmyAXnoU2e7ECu7gaQpxQrJSa0NndwwPYOUHoa2w=";
    };
  });
}

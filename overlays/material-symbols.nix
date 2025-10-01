final: prev: {
  material-symbols = prev.material-symbols.overrideAttrs (old: {
    version = "4.0.0-unstable-2025-09-19";
    src = prev.fetchFromGitHub {
      owner = "google";
      repo = "material-design-icons";
      rev = "bb04090f930e272697f2a1f0d7b352d92dfeee43";
      hash = "sha256-aFKG8U4OBqh2hoHYm1n/L4bK7wWPs6o0rYVhNC7QEpI=";
      sparseCheckout = [ "variablefont" ];
    };
  });
}

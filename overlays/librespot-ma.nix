final: prev:
{
  librespot-ma = final.rustPlatform.buildRustPackage {
    pname = "librespot";
    version = "ma-fork";

    src = final.fetchFromGitHub {
      owner = "music-assistant";
      repo = "librespot";
      rev = "accecb60a16334013c0c99a5ded553794ee871b7";
      hash = "sha256-vPiI8llXB6+ahX+iad/Ut81D3iZcTSVmYGDXXwApk/w=";
    };
    cargoHash = "sha256-Lujz2revTAok9B0hzdl8NVQ5XMRY9ACJzoQHIkIgKMg=";

    nativeBuildInputs = [ final.pkg-config final.makeWrapper ];
    buildInputs = [ final.openssl ];
  };
}

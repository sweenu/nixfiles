final: prev:
let
  nodejs = prev.nodejs_22;
  yarn-berry = prev.yarn-berry_4.override { inherit nodejs; };
  version = "unstable-2026-05-11";
  src = prev.fetchFromGitHub {
    name = "actualbudget-actual-source";
    owner = "actualbudget";
    repo = "actual";
    rev = "0fd510a1d4a953083dbeed1b6b2e52dfb60292af";
    hash = "sha256-6kj0wqheqEtunNH5tD7IuF6HYnIcnATu7P0oRQGmop4=";
  };
in
{
  actual-server = prev.actual-server.overrideAttrs (old: {
    inherit version src;
    srcs = [
      src
      old.passthru.translations
    ];
    missingHashes = ./actual-server-missing-hashes.json;
    offlineCache = yarn-berry.fetchYarnBerryDeps {
      inherit src;
      missingHashes = ./actual-server-missing-hashes.json;
      hash = "sha256-R+cU6iC5OIGsdYRfwVaCgwMQBr5VULJ9ZMkofVejjN8=";
    };
    nativeBuildInputs = old.nativeBuildInputs ++ [ prev.git ];
    preBuild = ''
      git init
      git add -A
      git -c user.email="nix@nixos" -c user.name="Nix" commit -m "init" --allow-empty
    '';
    postInstall = ''
      mkdir -p $out/lib/actual/packages/crdt
      cp -r ./packages/crdt/dist $out/lib/actual/packages/crdt/
      cp ./packages/crdt/package.json $out/lib/actual/packages/crdt/
    '';
  });
}

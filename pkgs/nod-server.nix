{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs_24,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  makeWrapper,
  docker-client,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nod-server";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "n8n-io";
    repo = "nod";
    rev = "9c58eeb998ca4c5d4ee9f645d739303ed82c3c30";
    hash = "sha256-PTI70VB+cOzDwxenxk258/PfpiRDkgDQOPUgdwGIhNo=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-tMWbT1vt4r4QkJkpNMpwVPLiimdkgCkSlXElG4kqk3k=";
  };

  nativeBuildInputs = [
    nodejs_24
    pnpmConfigHook
    pnpm_10
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild
    pnpm exec vite build
    CI=true pnpm --ignore-scripts prune --prod
    find node_modules -xtype l -delete
    runHook postBuild
  '';

  # Same layout as deployment/self-host/Dockerfile: the server runs its TypeScript through tsx.
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/nod/docs/src/content $out/bin
    cp -r package.json node_modules src dist $out/lib/nod/
    cp -r docs/src/content/docs $out/lib/nod/docs/src/content/
    makeWrapper ${lib.getExe nodejs_24} $out/bin/nod-server \
      --chdir $out/lib/nod \
      --add-flags "--import tsx src/server/index.ts" \
      --prefix PATH : ${lib.makeBinPath [ docker-client ]}
    runHook postInstall
  '';

  dontStrip = true;
  dontPatchELF = true;

  meta = {
    description = "Server for Nod, n8n's personal agent";
    homepage = "https://github.com/n8n-io/nod";
    license = lib.licenses.asl20;
    mainProgram = "nod-server";
    platforms = lib.platforms.linux;
  };
})

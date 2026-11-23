{
  lib,
  stdenvNoCC,
  fetchurl,
  ostree,
  buildFHSEnv,
  appimageTools,
  qemu_kvm,
  openssh,
}:

let
  pname = "nod";
  version = "0.9.6";

  part =
    n: hash:
    fetchurl {
      url = "https://github.com/n8n-io/nod/releases/download/nod-v${version}/nod-linux-x64.flatpak.part${n}";
      inherit hash;
    };

  # Upstream's only Linux artifact is a Flatpak bundle, split to fit GitHub's 2 GiB asset
  # limit. It can't be built from source in the sandbox: the runtime pack is a VM image
  # assembled with Docker.
  app = stdenvNoCC.mkDerivation {
    pname = "nod-app";
    inherit version;

    srcs = [
      (part "00" "sha256-OJZEz8UNJhYvb1oyYnpnbtBOyJ/L/rEQqSy5xMFG9kg=")
      (part "01" "sha256-RkYIPJVzpM33UDYk+SmAofWht8dsxaCn1I2VpXPu/34=")
    ];

    nativeBuildInputs = [
      ostree
    ];

    dontUnpack = true;
    # prebuilt Electron, node_modules and VM images, all run inside the FHS env below
    dontFixup = true;

    buildPhase = ''
      runHook preBuild
      cat $srcs > nod.flatpak
      ostree init --repo=repo --mode=bare-user-only
      ostree static-delta apply-offline --repo=repo nod.flatpak
      commit=$(cd repo/objects && echo */*.commit)
      commit=''${commit%.commit}
      ostree checkout --repo=repo -U "''${commit/\//}" checkout
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share
      mv checkout/files/nod $out/
      mv checkout/files/share/{applications,icons,metainfo} $out/share/
      runHook postInstall
    '';
  };
in
buildFHSEnv (
  appimageTools.defaultFhsEnvArgs
  // {
    inherit pname version;

    # the Flatpak ships its own qemu and ssh for Lima, which looks for them in /usr/bin
    targetPkgs =
      pkgs:
      appimageTools.defaultFhsEnvArgs.targetPkgs pkgs
      ++ [
        qemu_kvm
        openssh
      ];

    # usage analytics are on by default and fire before the in-app switch is reachable
    profile = ''
      export NOD_ANALYTICS_ENABLED=false
    '';

    # Electron only picks a keyring by itself on GNOME and KDE, and Nod refuses to save
    # keys without one
    runScript = "${app}/nod/nod --password-store=gnome-libsecret";

    extraInstallCommands = ''
      ln -s ${app}/share $out/share
    '';

    meta = {
      description = "Open source personal agent from n8n";
      homepage = "https://nod.n8n.io";
      license = lib.licenses.asl20;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "nod";
    };
  }
)

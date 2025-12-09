{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

let
  modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/usb/realtek-r8152";
in
stdenv.mkDerivation rec {
  pname = "realtek-r8152";
  name = "${pname}-${version}-${kernel.version}";
  version = "2.21.4";

  src = fetchFromGitHub {
    owner = "wget";
    repo = "realtek-r8152-linux";
    rev = "v${version}";
    hash = "sha256-6lLVrDY1uCx7y4CgBnQWfsXWyQD67/iAijKYHqYbKfU=";
    fetchSubmodules = true;
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "-C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "modules"
  ];

  preBuild = ''
    absSrc=$(realpath .)
    makeFlagsArray+=(M=$absSrc)
  '';

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p ${modDestDir}
    find . -name '*.ko' -exec cp --parents {} ${modDestDir} \;
    find ${modDestDir} -name '*.ko' -exec xz -f {} \;

    mkdir -p $out/lib/udev/rules.d
    cp 50-usb-realtek-net.rules $out/lib/udev/rules.d/50-realtek-r8152.rules
  '';

  meta = with lib; {
    description = "Kernel module for Realtek RTL8152/RTL8153 Based USB Ethernet Adapters";
    longDescription = ''
      Realtek r8152 driver for USB Ethernet adapters. Includes udev rules to set correct
      USB configuration modes for supported devices.
    '';
    homepage = "https://github.com/wget/realtek-r8152-linux";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ "sweenu" ];
  };
}

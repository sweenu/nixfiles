{
  lib,
  python3Packages,
  fetchFromGitHub,
  portaudio,
  alsa-lib,
}:

python3Packages.buildPythonApplication rec {
  pname = "sendspin-cli";
  version = "1.2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Sendspin";
    repo = "sendspin-cli";
    rev = "1.2.4";
    hash = "sha256-z8ieaDHv4C6WNLpPGybhcfB+E6Jj/rCc7zSRpL6vdk0=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    aiosendspin
    av
    numpy
    qrcode
    readchar
    rich
    sounddevice
  ];

  buildInputs = [
    portaudio
    alsa-lib
  ];

  # sounddevice needs portaudio at runtime
  makeWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        portaudio
        alsa-lib
      ]
    }"
  ];

  pythonImportsCheck = [ "sendspin" ];

  meta = {
    description = "Synchronized audio player for Sendspin servers";
    homepage = "https://github.com/Sendspin/sendspin-cli";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "sendspin";
  };
}

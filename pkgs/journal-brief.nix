{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "journal-brief";
  version = "1.1.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "twaugh";
    repo = "journal-brief";
    tag = "v${version}";
    hash = "sha256-Q0ydbIwn0w5rnZ4o1k9/XZLHHczIxvYIJvUscBAR120=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pyyaml
    systemd-python
  ];

  doCheck = false;

  meta = {
    description = "Show interesting new systemd journal entries since last run";
    homepage = "https://github.com/twaugh/journal-brief";
    license = lib.licenses.gpl2Plus;
    mainProgram = "journal-brief";
  };
}

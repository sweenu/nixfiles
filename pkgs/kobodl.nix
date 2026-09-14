{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "kobodl";
  version = "0.14.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "subdavis";
    repo = "kobo-book-downloader";
    tag = version;
    hash = "sha256-z1q5kqcyJFbmRzQQyAIjDk3lBholwcKsbrsss5eOumQ=";
  };

  build-system = with python3Packages; [ poetry-core ];

  # `dataclasses` is the stdlib backport, unneeded since python 3.7
  pythonRemoveDeps = [ "dataclasses" ];

  pythonRelaxDeps = [
    "dataclasses-json"
    "flask"
    "setuptools"
    "tabulate"
  ];

  dependencies = with python3Packages; [
    beautifulsoup4
    click
    dataclasses-json
    flask
    pycryptodome
    requests
    setuptools
    tabulate
  ];

  pythonImportsCheck = [ "kobodl" ];

  meta = {
    description = "Fetch personal Kobo books and audiobooks, and remove their DRM";
    homepage = "https://github.com/subdavis/kobo-book-downloader";
    license = lib.licenses.unlicense;
    mainProgram = "kobodl";
  };
}

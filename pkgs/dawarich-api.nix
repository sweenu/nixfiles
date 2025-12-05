{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  pythonOlder,
  aiohttp,
  pydantic,
}:

buildPythonPackage rec {
  pname = "dawarich-api";
  version = "0.4.1";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "AlbinLind";
    repo = "dawarich-api";
    tag = version;
    hash = "sha256-nR06P2QvC9/RxeX3CcehTDlyk7EwZ33ryKRG8sjfp3s=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    aiohttp
    pydantic
  ];

  doCheck = false;

  pythonImportsCheck = [
    "dawarich_api"
  ];
}

{
  lib,
  aiohttp,
  pydantic,
  buildPythonPackage,
  fetchPypi,
  uv-build,
}:

buildPythonPackage rec {
  pname = "aiobbox";
  version = "0.3.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/UyyhqvIcfMwrisbUF5AEiwzIUAfQxvmjxQL9ppsj9g=";
  };

  propagatedBuildInputs = [
    aiohttp
    pydantic
  ];

  nativeBuildInputs = [
    uv-build
  ];

  pythonImportsCheck = [ "aiobbox" ];
}

{
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

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.19,<0.9.0" "uv_build"
  '';

  propagatedBuildInputs = [
    aiohttp
    pydantic
  ];

  nativeBuildInputs = [
    uv-build
  ];

  pythonImportsCheck = [ "aiobbox" ];
}

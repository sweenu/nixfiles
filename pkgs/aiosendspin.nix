{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  aiohttp,
  av,
  mashumaro,
  orjson,
  pillow,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "aiosendspin";
  version = "1.2.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SDoX0VUM2HBmbEwrklfrkryrZuXrg8IW6mdupklhvoo=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    av
    mashumaro
    orjson
    pillow
    zeroconf
  ];

  pythonImportsCheck = [ "aiosendspin" ];

  # Tests require network access
  doCheck = false;

  meta = {
    description = "Async Python implementation of the Sendspin Protocol";
    homepage = "https://github.com/Sendspin-Protocol/sendspin";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}

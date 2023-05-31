{ lib
, buildPythonPackage
, fetchFromGitHub
, pybind11
, poetry-core
, setuptools
}:

buildPythonPackage rec {
  pname = "cnest";
  version = "1.0.6";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "HorizonRobotics";
    repo = pname;
    rev = "b8322896d8f42c0a155d4bd62ea62eb7687ff507";
    hash = "sha256-i31oKkrMnYsvogpj1x8fZ4tbusZoaSAwRXTOsp7UdUI=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  buildInputs = [
    pybind11
    setuptools
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/HorizonRobotics/alf/tree/pytorch/alf/nest";
    description = "C++ implementation of several key nest functions that are preformance critical";
    license = licenses.mit;
    maintainers = with maintainers; [ breakds ];
  };
}

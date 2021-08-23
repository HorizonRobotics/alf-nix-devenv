{ lib
, buildPythonPackage
, fetchPypi
, pybind11
, poetry
}:

buildPythonPackage rec {
  pname = "cnest";
  version = "1.0.4";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-TAPQTYjowWlIZWhjv5zXCW0GYF8Z26XeQB5HQ+CXthk=";
  };

  buildInputs = [
    pybind11
    poetry
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/HorizonRobotics/alf/tree/pytorch/alf/nest";
    description = "C++ implementation of several key nest functions that are preformance critical";
    license = licenses.mit;
    maintainers = with maintainers; [ breakds ];
  };
}

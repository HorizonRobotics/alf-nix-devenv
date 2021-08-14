{ lib
, buildPythonPackage
, fetchPypi
, pybind11
, poetry
}:

buildPythonPackage rec {
  pname = "cnest";
  version = "1.0.1";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-zHdVQdgH3E8FLQJ6UkNsbShGsDscz8cW7n6bcgAny0g=";
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

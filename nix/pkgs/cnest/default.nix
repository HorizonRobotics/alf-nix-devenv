{ lib, buildPythonPackage, pybind11 }:

buildPythonPackage rec {
  pname = "cnest";
  version = "1.0-trunk";

  # TODO(breakds): Split cnest out of alf and create a separate
  # pacakge out of it.
  #
  # The current cnest comes from
  # https://github.com/HorizonRobotics/alf/tree/236469870d5de74bb504c62c9f1bf1b0d1553b68/alf/nest/cnest
  src = ./cnest;

  buildInputs = [
    pybind11
  ];

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/HorizonRobotics/alf/tree/pytorch/alf/nest";
    description = "C++ implementation of several key nest functions that are preformance critical";
    license = licenses.asl20;
    maintainers = with maintainers; [ breakds ];
  };
}

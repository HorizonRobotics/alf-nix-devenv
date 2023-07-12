{ lib
, buildPythonPackage
, pythonOlder
, cmake
, pybind11
, easyloggingpp
, librealsensex
, numpy
}:

buildPythonPackage rec {
  pname = "real-sense-sensor";
  version = "1.0.0";
  format = "setuptools";

  disabled = pythonOlder "3.8";

  src = ./.;

  propagatedBuildInputs = [
    numpy
  ];

  buildInputs = [
    pybind11
    easyloggingpp
    librealsensex
  ];

  nativeBuildInputs = [
    cmake
  ];

  dontUseCmakeConfigure = true;

  pythonImportCheck = [ "real_sense_sensor" ];

  meta = with lib; {
    description = ''
      Customized pybind wrapper for librealsense2
    '';
    homepage = "https://github.com/HorizonRoboticsInternal/librealsense";
    license = licenses.asl20;
    maintainers = with maintainers; [ breakds ];
  };
}

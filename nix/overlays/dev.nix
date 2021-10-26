{ pytorchWithCuda11
, torchvisionWithCuda11
, procgen
, atari-py-with-rom
, pytorchvizWithCuda11
, highway-env
, metadrive-simulator
}:

final: prev: rec {
  python3 = prev.python3.override {
    packageOverrides = pyFinal: pyPrev: rec {
      cnest = pyFinal.callPackage ../pkgs/cnest {};

      rectangle-packer = pyFinal.callPackage ../pkgs/rectangle-packer {};

      pybox2d = pyFinal.callPackage ../pkgs/pybox2d {};

      gin-config = pyFinal.callPackage ../pkgs/gin-config {};

      jedi = pyFinal.callPackage ../pkgs/jedi {};

      pudb = pyFinal.callPackage ../pkgs/pudb {};

      inherit pytorchWithCuda11 torchvisionWithCuda11 pytorchvizWithCuda11
        procgen atari-py-with-rom highway-env metadrive-simulator;
    };
  };

  python3Packages = python3.pkgs;
}

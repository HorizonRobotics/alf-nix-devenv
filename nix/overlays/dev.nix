{ pytorchWithCuda11
, torchvisionWithCuda11
, procgen
, atari-py-with-rom
, pytorchvizWithCuda11
, highway-env
, metadrive-simulator
}:

let original-metadrive-simulator = metadrive-simulator;
    
in final: prev: rec {
  python3 = prev.python3.override {
    packageOverrides = pyFinal: pyPrev: rec {
      cnest = pyFinal.callPackage ../pkgs/cnest {};

      rectangle-packer = pyFinal.callPackage ../pkgs/rectangle-packer {};

      pybox2d = pyFinal.callPackage ../pkgs/pybox2d {};
      
      gin-config = pyFinal.callPackage ../pkgs/gin-config {};

      jedi = pyFinal.callPackage ../pkgs/jedi {};

      pudb = pyFinal.callPackage ../pkgs/pudb {};

      # Use the the tqdm altered by this overlay.
      metadrive-simulator = original-metadrive-simulator.override {
        inherit (pyFinal) tqdm;
      };

      inherit pytorchWithCuda11 torchvisionWithCuda11 pytorchvizWithCuda11
        procgen atari-py-with-rom highway-env;
    };
  };

  python3Packages = python3.pkgs;
}

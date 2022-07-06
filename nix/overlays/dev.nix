{ pytorchWithCuda11
, procgen
, atari-py-with-rom
, pytorchvizWithCuda11
, highway-env
, metadrive-simulator
, tensor-splines
, gym
, mujoco
}:

let original-metadrive-simulator = metadrive-simulator;
    original-tensor-splines = tensor-splines;
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

      einops = pyFinal.callPackage ../pkgs/einops/default.nix {
        pytorch = pytorchWithCuda11;
      };

      torchvision101 = pyFinal.callPackage ../pkgs/torchvision {
        pytorch = pytorchWithCuda11;
      };      

      inherit pytorchWithCuda11 pytorchvizWithCuda11
        procgen atari-py-with-rom highway-env gym mujoco;

      tensor-splines = pyFinal.callPackage original-tensor-splines.override {
        pytorch = pytorchWithCuda11;
      };
    };
  };

  python3Packages = python3.pkgs;
}

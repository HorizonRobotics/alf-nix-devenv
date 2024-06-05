{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonRelaxDepsHook
, pybind11
, boost
, torchWithCuda
, torchvision
, numpy
, einops
, wandb
, tensorboard
, absl-py
, pyglet
, opencv4
, pathos
, pillow
, psutil
, gin-config
, cnest
, fasteners
, rectangle-packer
, pybox2d
, matplotlib
, tqdm
, gym
, pybullet
, atari-py-with-rom
, procgen
, highway-env
, metadrive-simulator
, threadpoolctl
}:

buildPythonPackage rec {
  pname = "alf";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "HorizonRobotics";
    repo = "alf";
    # This rev has an extra cherry-pick: Haonan's unsubmitted PR's commit
    # "support alpha=0 for SAC", and therefore is temporary
    rev = "7d85906d0b70d51e3b79d474cfffbc53abd3a29e";
    hash = "sha256-1rt/4u/JdPunE3c77h87Qf/eN7Ez5mEpnrDGdmc/Z+A=";
  };

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  buildInputs = [
    pybind11
    boost
  ];

  pythonRelaxDeps = [
    "matplotlib"
    "torchvision"
    "h5py"
    "pillow"
    "pyglet"
    "pybullet"
    "torch"
    "pathos"
    "atari-py"
    "rectangle-packer"
    "procgen"
    "tensorboard"
    "gym"
  ];

  propagatedBuildInputs = [
    # Machine Learning
    torchWithCuda
    torchvision
    numpy
    einops
    wandb
    tensorboard

    # Utils
    absl-py
    pyglet
    opencv4
    pathos
    pillow
    psutil
    gin-config
    cnest
    fasteners
    rectangle-packer
    pybox2d
    matplotlib
    tqdm
    threadpoolctl

    # Simulators
    gym
    pybullet
    atari-py-with-rom
    procgen
    highway-env
    metadrive-simulator
  ];

  doCheck = false;

  pythonImportsCheck = [ "alf" ];

  meta = with lib; {
    description = ''
      Agent Learning Framework (ALF) is a reinforcement learning framework
      emphasizing on the flexibility and easiness of implementing complex
      algorithms involving many different components
    '';
    homepage = "https://alf.readthedocs.io/en/latest/index.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ breakds ];
  };
}

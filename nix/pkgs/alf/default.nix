{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonRelaxDepsHook
, pybind11
, boost
, pytorchWithCuda11
, torchvisionWithCuda11
, torchWithoutCuda
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
# Options
, useCuda ? true
}:

buildPythonPackage rec {
  pname = "alf";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "HorizonRobotics";
    repo = "alf";
    # This rev has an extra cherry-pick: Haonan's unsubmitted PR's commit
    # "support alpha=0 for SAC", and therefore is temporary
    rev = "401b7a78151353a5e4ee2603e096d326f34f11cf";
    hash = "sha256-IB+wkMJbWwsdr3gTU+LP9jAQemG54mvlggAgQaqvzJU=";
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

  propagatedBuildInputs = let torch-deps = if useCuda then [
    pytorchWithCuda11
    torchvisionWithCuda11
  ] else [
    torchWithoutCuda
  ]; in [
    # Machine Learning
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

    # Simulators
    gym
    pybullet
    atari-py-with-rom
    procgen
    highway-env
    metadrive-simulator
  ] ++ torch-deps;

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

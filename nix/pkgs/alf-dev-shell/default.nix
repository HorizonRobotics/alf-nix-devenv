# This is a development environment for agent learning framework.

{ mkShell
, python3
, clang-tools_9
, cpplint
, rsync
, nodePackages
, boost }:

let pythonForAlf = python3.withPackages (pyPkgs: with pyPkgs; [
      # For both Dev and Deploy
      torchWithCuda
      torchvision
      numpy pandas absl-py
      gym
      # TODO(breakds): Require pyglet 1.3.2, because higher version
      # breaks classic control rendering. Or fix the classic control
      # rendering.
      pyglet
      mediapy  # For rendering
      opencv4
      pathos
      pillow
      psutil
      pybullet
      sphinx
      gin-config
      cnest
      fasteners
      rectangle-packer
      pybox2d
      einops
      tensor-splines
      wandb
      # TODO(breakds): Package torchtext and enable it.
      # torchtext (0.9.1)

      pydantic

      # Simulators
      atari-py-with-rom
      procgen
      highway-env
      metadrive-simulator
      mujoco-pybind
      mujoco-menagerie
      
      # Dev only packages
      jupyterlab ipywidgets
      matplotlib tqdm
      sphinx_rtd_theme
      yapf
      pylint
      pudb
      rich
      pytorchviz
      pre-commit
      pybind11  # for _penv
    ]);

    pythonIcon = "f3e2";

in mkShell rec {
  name = "ALF";

  packages = [
    pythonForAlf
    nodePackages.pyright
    rsync # Alf Snapshot needs this
    clang-tools_9 # For clang-format stuff
    cpplint
    boost  # for _penv
  ];

  # This is to have a leading python icon to remind the user we are in
  # the Alf python dev environment.
  shellHook = ''
    export PS1="$(echo -e '\u${pythonIcon}') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (${name}) \\$ \[$(tput sgr0)\]"

    # We need this when deterministic algorithm is enabled in pytorch.
    # See https://docs.nvidia.com/cuda/cublas/index.html#cublasApi_reproducibility
    # This will increase library footprint in GPU memory by approximately 24MiB
    CUBLAS_WORKSPACE_CONFIG=:4096:8
  '';
}

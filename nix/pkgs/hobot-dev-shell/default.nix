# This is a development environment for Hobot

{ lib
, mkShell
, python3
, nodePackages
, libGL }:

let libPath = lib.makeLibraryPath [
  libGL
];

in mkShell {
  name = "hobot";
  packages = let pythonDevEnv = python3.withPackages (pyPkgs: with pyPkgs; [
    alf

    # Utils
    numpy-quaternion

    # Simulators
    mujoco-pybind
    mujoco-menagerie
    dm-control
    python-fcl

    # Deveopment Tools
    sphinx
    sphinx_rtd_theme
    jupyterlab
    ipywidgets
    yapf
    pylint
    pudb
    rich
    pytorchvizWithCuda11
    pre-commit
  ]); in [
    pythonDevEnv
    nodePackages.pyright
    libGL
  ];

  LD_LIBRARY_PATH = libPath;
}

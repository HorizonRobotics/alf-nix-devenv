# This is a development environment for Hobot

{ mkShell
, python3
, nodePackages }:

mkShell {
  name = "hobot";
  packages = let pythonDevEnv = python3.withPackages (pyPkgs: with pyPkgs; [
    alf

    # Utils
    numpy-quaternion

    # Simulators
    mujoco-pybind
    mujoco-menagerie

    # Deveopment Tools
    sphinx
    sphinx_rtd_theme
    jupyterlab
    yapf
    pylint
    pudb
    rich
    pytorchvizWithCuda11
    pre-commit
  ]); in [
    pythonDevEnv
    nodePackages.pyright
  ];
}

# This is a development environment for Hobot

{ lib
, stdenv
, mkShell
, python3
, nodePackages
, libGL
, useLegacyMujoco ? false }:

let libPath = lib.makeLibraryPath [
      libGL
    ];

in mkShell {
  name = "hobot";
  packages = let pythonDevEnv = python3.withPackages (pyPkgs: with pyPkgs; [
    alf

    # Utils
    mediapy  # absl needs it
    numpy-quaternion
    jinja2
    scikit-image

    # Simulators
    mujoco-menagerie
    python-fcl

    # Physical Robot
    pyunitree
    pysagittarius

    # Deveopment Tools
    sphinx
    sphinx_rtd_theme
    jupyterlab
    ipywidgets
    ipympl
    jupyterlab-widgets
    yapf
    pylint
    pudb
    rich
    pytorchvizWithCuda11
    pre-commit
    bokeh
    snakeviz

    # Application Libraries (Optional)
    tkinter
    websocket-client
    questionary
    click
  ] ++ (
    if useLegacyMujoco then [
      mujoco-menagerie
      mujoco-pybind-231
      dm-control-109
    ] else [
      mujoco-menagerie
      mujoco-pybind
      dm-control
    ]
  )); in [
    pythonDevEnv
    nodePackages.pyright
    libGL
  ];

  LD_LIBRARY_PATH = libPath;

  shellHook = ''
    export PS1="$(echo -e '\uf3e2') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (hobot) \\$ \[$(tput sgr0)\]"
    # Manually set where to look for libstdc++.so.6
    export LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
    export PYTHONPATH="$(pwd):$PYTHONPATH"
  '';
}

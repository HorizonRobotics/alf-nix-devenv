# This is a development environment for Hobot

{ lib
, stdenv
, mkShell
, python3
, nodePackages
, libGL
, libGLU
, cpplint
, cmake
}:

let libPath = lib.makeLibraryPath [
      libGL
    ];

in mkShell {
  name = "hobot";
  packages = let pythonDevEnv = python3.withPackages (pyPkgs: with pyPkgs; [
    alf
    pybind11

    # Utils
    mediapy  # absl needs it
    numpy-quaternion
    jinja2
    scikit-image
    webcolors

    # Simulators
    mujoco-pybind
    mujoco-menagerie
    dm-control
    python-fcl

    # Physical Robot
    pyunitree
    pyrealsense2WithoutCuda
    # real-sense-sensor

    # Deveopment Tools
    questionary
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

    # Application Libraries (Optional)
    tkinter
    websocket-client
    questionary
    click
    loguru
  ]); in [
    pythonDevEnv
    nodePackages.pyright
    cpplint
    libGL
    libGLU
    cmake
  ];

  LD_LIBRARY_PATH = libPath;

  shellHook = ''
    export PS1="$(echo -e '\uf3e2') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (hobot) \\$ \[$(tput sgr0)\]"
    # Manually set where to look for libstdc++.so.6
    export LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
    export PYTHONPATH="$(pwd):$PYTHONPATH"
  '';
}

# This is a development environment for Hobot

{ lib
, stdenv
, mkShell
, python3
, nodePackages
, libGL
, libGLU
, cpplint
, unitree-cli
, useLegacyMujoco ? false
, withRealSense ? true}:

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
    mujoco-menagerie
    python-fcl
    sapien

    # Physical Robot
    pyunitree
    pyrealsense2WithoutCuda

    # Models
    LIV-robotics

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
    loguru
    wget
    xmltodict

    # Deployment
    pyrealsense2WithoutCuda
    real-sense-sensor
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
    cpplint
    libGL
    libGLU
    unitree-cli
  ];

  LD_LIBRARY_PATH = libPath;

  shellHook = ''
    export PS1="$(echo -e '\uf3e2') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (hobot) \\$ \[$(tput sgr0)\]"
    export LD_LIBRARY_PATH=${libGLU}/lib:${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
    export PYTHONPATH="$(pwd):$PYTHONPATH"
  '';
}

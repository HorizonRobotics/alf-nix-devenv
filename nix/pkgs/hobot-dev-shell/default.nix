# This is a development environment for Hobot

{ lib
, stdenv
, mkShell
, python3
, nodePackages
, libGL
, libGLU
, cpplint
, pylyzer
, pkg-config
, gst_all_1
, stream-zed
, useLegacyMujoco ? false
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
    kincpp

    # Simulators
    python-fcl
    sapien
    pyopengl-accelerate
    procthor

    # Models
    LIV-robotics

    # Deployment
    pyrealsense2WithoutCuda    

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
    torchWithCuda
    pre-commit
    bokeh
    snakeviz
    jax
    equinox
    jaxtyping
    chex

    # Application Libraries (Optional)
    tkinter
    websocket-client
    questionary
    click
    loguru
    wget
    xmltodict
    fastapi
    uvicorn
    websockets
  ] ++ (
    if useLegacyMujoco then [
      mujoco-menagerie
      mujoco-pybind-231
      dm-control-109
    ] else [
      mujoco-menagerie
      mujoco-pybind
      mujoco-mjx
      dm-control
    ]
  )); in [
    pythonDevEnv
    nodePackages.pyright
    pylyzer
    cpplint
    libGL
    libGLU

    # gstreamer
    pkg-config    
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base  # appsrc
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav         # avdec_h264

    # ZED Mini streaming tools
    stream-zed

    # Build Tools
    cmake
  ];

  LD_LIBRARY_PATH = libPath;

  shellHook = ''
    export PS1="$(echo -e '\uf3e2') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (hobot) \\$ \[$(tput sgr0)\]"
    export LD_LIBRARY_PATH=${libGLU}/lib:${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
    export PYTHONPATH="$(pwd):$PYTHONPATH"
  '';
}

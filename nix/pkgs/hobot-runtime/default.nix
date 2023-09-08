{ dockerTools
, buildEnv
, stdenv
, python3
, python3Packages
, bash
, git
, iputils
, coreutils
, findutils
, fd
, openssl
, openssh
, curl
, cacert
, ncurses
, libGL
, screen
, nvitop
, useLegacyMujoco ? false
}:

let runtime-base = dockerTools.buildLayeredImage {
      name = "runtime-base";
      tag = "latest";
      created = "now";

      contents = [
        bash
        git
        iputils
        coreutils
        findutils
        fd
        openssl
        openssh
        curl
        screen
        ncurses  # For the pretty PS1
        libGL
      ];

      config = {
        Cmd = [ "/bin/bash" ];
        Env = [
          # The following environment variables makes it possible for the docker
          # container to access internet with SSL/HTTPS.
          "GIT_SSL_CAINFO=${cacert}/etc/ssl/certs/ca-bundle.crt"
          "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
        ];
      };
    };

    hobot-python-env = python3.withPackages (pyPkgs: with pyPkgs; [
      alf

      # Utils
      mediapy  # absl needs it
      numpy-quaternion
      jinja2

      # Simulators
      mujoco-menagerie
      python-fcl

      # Physical Robot
      pyunitree
      pysagittarius

      # Deveopment Tools
      yapf
      pylint
      pudb
      pytorchvizWithCuda11

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
    ));

    version = "2023.05.25";

in dockerTools.buildImage {
  name = "hobot-runtime";
  tag = if useLegacyMujoco then "${version}-legacy" else version;
  created = "now";

  fromImage = runtime-base;

  copyToRoot = buildEnv {
    name = "runtime-base-env";
    paths = [ hobot-python-env nvitop ];
    pathsToLink = [ "/bin" ];
  };

  config = {
    Cmd = [ "/bin/bash" ];
    Env = let
      cudatoolkit = python3Packages.pytorchWithCuda11.cudaPackages.cudatoolkit;
      cudnn = python3Packages.pytorchWithCuda11.cudaPackages.cudnn;
    in [
      "PS1=\\e[33m\\w\\e[m [\\t] \\e[31m\\\\$\\e[m "
      # The following enables talking to nvidia driver on the host with CUDA.
      # Without them, `torch.cuda.is_available()` will be `False`.
      "LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib:${cudatoolkit}/lib:${cudatoolkit.lib}/lib:${cudnn}/lib:/usr/lib64"
      "NVIDIA_DRIVER_CAPABILITIES=compute,utility"
      "NVIDIA_VISIBLE_DEVICES=all"
    ];
  };
}

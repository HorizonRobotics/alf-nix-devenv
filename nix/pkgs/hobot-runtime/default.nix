{ dockerTools
, buildEnv
, stdenv
, python3
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

in dockerTools.buildImage {
  name = "hobot-runtime";
  tag = "2023.05.24";
  created = "now";

  fromImage = runtime-base;

  copyToRoot = buildEnv {
    name = "runtime-base-env";
    paths = [ hobot-python-env nvitop ];
    pathsToLink = [ "/bin" ];
  };

  config = {
    Cmd = [ "/bin/bash" ];
    Env = [
      "PS1=\\e[33m\\w\\e[m [\\t] \\e[31m\\\\$\\e[m "
      "LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
    ];
  };
}

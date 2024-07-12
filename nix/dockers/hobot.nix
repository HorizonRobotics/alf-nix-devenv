{ dockerTools
, mkShell
, stdenv
, buildEnv
, python3
, bashInteractive
, iputils
, coreutils
, findutils
}:


let barebone = dockerTools.buildLayeredImage {
      name = "barebone";
      tag = "latest";

      contents = [
        bashInteractive
        iputils
        coreutils
        findutils
      ] ++ (with dockerTools; [
        caCertificates
        usrBinEnv
        binSh
        fakeNss
      ]);
    };

    python-env = python3.withPackages (p: with p; [
      numpy
    ]);

in dockerTools.buildLayeredImage {
  name = "hobot-cuda";
  tag = "latest";
  created = "now";
  maxLayers = 512;

  fromImage = barebone;

  contents = [
    python-env
  ];

  config = {
    Env = [
      "NVIDIA_VISIBLE_DEVICES=all"
      "NVIDIA_DRIVER_CAPABILITIES=all"
      "LD_LIBRARY_PATH=/usr/lib64/"
    ];
  };
}

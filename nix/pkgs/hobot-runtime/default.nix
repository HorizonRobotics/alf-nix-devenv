{ dockerTools
, buildEnv
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
, lsd
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

in dockerTools.buildImage {
  name = "hobot-runtime";
  tag = "latest";
  created = "now";

  fromImage = runtime-base;

  copyToRoot = buildEnv {
    name = "runtime-base-env";
    paths = [ lsd ];
    pathsToLink = [ "/bin" ];
  };

  config = {
    Cmd = [ "/bin/bash" ];
  };
}

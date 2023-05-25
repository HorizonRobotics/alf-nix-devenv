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
}:

dockerTools.buildImage {
  name = "hobot-runtime";
  tag = "latest";
  created = "now";

  copyToRoot = buildEnv {
    name = "root-environment";
    paths = [
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
    pathsToLink = [ "/bin" ];
  };

  config = {
    Cmd = [ "/bin/bash" ];
    Env = [
      "GIT_SSL_CAINFO=${cacert}/etc/ssl/certs/ca-bundle.crt"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };        
}

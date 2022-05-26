# NOTE that since 21.11, einops has already entered nixpkgs

{ lib
, fetchFromGitHub
, buildPythonPackage
, numpy
, nose
, nbformat
, nbconvert
, jupyter
, chainer
, parameterized
, pytorch
}:

buildPythonPackage rec {
  pname = "einops";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "arogozhnikov";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-n4R4lcRimuOncisCTs2zJWPlqZ+W2yPkvkWAnx4R91s=";
  };

  # The tests requires both tensorflow and mxnet which we do not intend to use.
  doCheck = false;

  meta = {
    description = "Flexible and powerful tensor operations for readable and reliable code";
    homepage = "https://github.com/arogozhnikov/einops";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yl3dy ];
  };
}

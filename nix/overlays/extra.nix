final: prev: rec {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      cnest = python-final.callPackage ../pkgs/cnest {};

      rectangle-packer = python-final.callPackage ../pkgs/rectangle-packer {};

      pybox2d = python-final.callPackage ../pkgs/pybox2d {};

      gin-config = python-final.callPackage ../pkgs/gin-config {};

      pre-commit = python-final.callPackage ../pkgs/pre-commit {};
    })
  ];
}

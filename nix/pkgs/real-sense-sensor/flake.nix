{
  description = "Pybind11 wrapper for librealsensex";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    utils.url = "github:numtide/flake-utils";

    librealsensex.url = "github:HorizonRoboticsInternal/librealsense/PR/breakds/real_sense_sensor";
    librealsensex.inputs.nixpkgs.follows = "nixpkgs";
    librealsensex.inputs.utils.follows = "utils";
  };

  outputs = { self, nixpkgs, utils, ... }@inputs: {
    overlays.default = nixpkgs.lib.composeManyExtensions [
      inputs.librealsensex.overlays.default
      (final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (py-final: py-prev: {
            real-sense-sensor = py-final.callPackage ./. {};
          })
        ];
      })
    ];
  } // utils.lib.eachSystem ["x86_64-linux"] (system: let

    pkgs-dev = import nixpkgs {
      inherit system;
      overlays = [
        inputs.librealsensex.overlays.default
      ];
    };

    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        self.overlays.default
      ];
    };

  in rec {
    devShells = {
      default = pkgs-dev.mkShell rec {
        name = "real-sense-sensor";

        packages = let pythonEnv = pkgs-dev.python3.withPackages (pyPkgs: with pyPkgs; [
          pybind11
        ]); in with pkgs-dev; [
          pythonEnv

          # C++/Pybind11
          cmake
          cmakeCurses
          easyloggingpp
          librealsensex
        ];

        shellHook = ''
          export PS1="$(echo -e '\uf3e2') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (${name}) \\$ \[$(tput sgr0)\]"
          export PYTHONPATH="$(pwd):$PYTHONPATH"
        '';
      };
    };

    packages.default = pkgs.python3Packages.real-sense-sensor;
  });
}

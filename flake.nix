{
  description = "Agent Learning Framework Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    utils.url = "github:numtide/flake-utils";

    ml-pkgs.url = "github:nixvital/ml-pkgs";
    ml-pkgs.inputs.nixpkgs.follows = "nixpkgs";
    ml-pkgs.inputs.utils.follows = "utils";

    tensor-splines.url = "git+ssh://git@github.com/HorizonRobotics/tensor-splines?ref=main";
    tensor-splines.inputs.nixpkgs.follows = "nixpkgs";
    tensor-splines.inputs.utils.follows = "utils";
    tensor-splines.inputs.ml-pkgs.follows = "ml-pkgs";

    unitree-go1-sdk.url = "git+ssh://git@github.com/HorizonRoboticsInternal/unitree-go1-sdk";
    unitree-go1-sdk.inputs.nixpkgs.follows = "nixpkgs";
    unitree-go1-sdk.inputs.utils.follows = "utils";

    sagittarius-sdk.url = "git+ssh://git@github.com/HorizonRoboticsInternal/sagittarius-sdk";
    sagittarius-sdk.inputs.nixpkgs.follows = "nixpkgs";
    sagittarius-sdk.inputs.utils.follows = "utils";

    librealsensex.url = "github:HorizonRoboticsInternal/librealsense/PR/breakds/real_sense_sensor";
    librealsensex.inputs.nixpkgs.follows = "nixpkgs";
    librealsensex.inputs.utils.follows = "utils";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    overlays = {
      extra = import ./nix/overlays/extra.nix;
      alf = nixpkgs.lib.composeManyExtensions [
        inputs.ml-pkgs.overlays.torch-family
        inputs.ml-pkgs.overlays.simulators
        inputs.tensor-splines.overlays.default
        self.overlays.extra
      ];
      hobot = nixpkgs.lib.composeManyExtensions [
        self.overlays.alf
        inputs.ml-pkgs.overlays.math
        inputs.unitree-go1-sdk.overlays.default
        inputs.sagittarius-sdk.overlays.default
        inputs.librealsensex.overlays.default
        (final: prev: {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (python-final: python-prev: {
              real-sense-sensor = python-final.callPackage ./nix/pkgs/real-sense-sensor {};
              alf = python-final.callPackage ./nix/pkgs/alf {};
              opencv4 = python-prev.opencv4.override {
                enableCuda = false;
              };
            })
          ];
        })
      ];
    };
  } // inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system:
    let pkgs-alf = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
            cudaCapabilities = [ "7.5" "8.6" ];
            cudaForwardCompat = false;
          };
          overlays = [ self.overlays.alf ];
        };

        pkgs-hobot = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
            cudaCapabilities = [ "7.5" "8.6" ];
            cudaForwardCompat = false;
          };
          overlays = [
            self.overlays.hobot
          ];
        };
    in {
      devShells = {
        alf-dev = pkgs-alf.callPackage ./nix/pkgs/alf-dev-shell {};
        hobot-dev = pkgs-hobot.callPackage ./nix/pkgs/hobot-dev-shell {
          useLegacyMujoco = false;
        };
      };

      packages = {
        # The following are the docker images for Hobot runtime. They are
        # currently under active development.
        hobot-runtime-legacy = pkgs-hobot.callPackage ./nix/pkgs/hobot-runtime {
          useLegacyMujoco = true;
        };
        hobot-runtime = pkgs-hobot.callPackage ./nix/pkgs/hobot-runtime {
          useLegacyMujoco = false;
        };
      };
      
    });
}

{
  description = "Agent Learning Framework Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    utils.url = "github:numtide/flake-utils";

    ml-pkgs.url = "github:nixvital/ml-pkgs";
    ml-pkgs.inputs.nixpkgs.follows = "nixpkgs";
    ml-pkgs.inputs.utils.follows = "utils";

    # Normally we use alf from a commit. In case you want to use a local alf
    # repo, commnet the following line and uncomment the line below it.
    alf.url = "github:HorizonRobotics/alf/PR/breakds/alf_packaged_new";
    # alf.url = "git+file:///home/breakds/projects/alf";
    alf.inputs.nixpkgs.follows = "nixpkgs";
    alf.inputs.ml-pkgs.follows = "ml-pkgs";
    alf.inputs.utils.follows = "utils";

    tensor-splines.url = "git+ssh://git@github.com/HorizonRobotics/tensor-splines?ref=main";
    tensor-splines.inputs.nixpkgs.follows = "nixpkgs";
    tensor-splines.inputs.utils.follows = "utils";
    tensor-splines.inputs.ml-pkgs.follows = "ml-pkgs";

    sagittarius-sdk.url = "git+ssh://git@github.com/HorizonRoboticsInternal/sagittarius-sdk";
    sagittarius-sdk.inputs.nixpkgs.follows = "nixpkgs";
    sagittarius-sdk.inputs.utils.follows = "utils";

    kincpp.url = "git+ssh://git@github.com/HorizonRoboticsInternal/kincpp?ref=main";
    kincpp.inputs.nixpkgs.follows = "nixpkgs";
    kincpp.inputs.utils.follows = "utils";

    relaxed-ik.url = "github:breakds/relaxed_ik_core";
    relaxed-ik.inputs.nixpkgs.follows = "nixpkgs";
    relaxed-ik.inputs.utils.follows = "utils";
  };

  outputs = { self, nixpkgs, alf, ... }@inputs: {
    overlays = {
      hobot = nixpkgs.lib.composeManyExtensions [
        alf.overlays.default
        inputs.ml-pkgs.overlays.jax-family        
        inputs.ml-pkgs.overlays.math
        inputs.sagittarius-sdk.overlays.default
        inputs.kincpp.overlays.default
        inputs.relaxed-ik.overlays.default
        (final: prev: {
          stream-zed = final.callPackage ./nix/pkgs/stream-zed {};
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (python-final: python-prev: {
              opencv4 = python-prev.opencv4.override {
                enableCuda = false;
                enableGtk3 = true;
              };
            })
          ];
        })
      ];
    };
  } // inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system:
   
    let pkgs-hobot = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
            cudaCapabilities = [ "7.5" "8.6" ];
            cudaForwardCompat = true;
          };
          overlays = [
            self.overlays.hobot
          ];
        };
    in {
      devShells = {
        hobot-dev = pkgs-hobot.callPackage ./nix/pkgs/hobot-dev-shell {};
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

        hobot-docker = pkgs-hobot.callPackage ./nix/dockers/hobot.nix {};
      };
    });
}

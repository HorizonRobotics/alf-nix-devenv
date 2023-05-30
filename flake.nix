{
  description = "Agent Learning Framework Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    utils.url = "github:numtide/flake-utils";

    ml-pkgs.url = "github:nixvital/ml-pkgs/dev/23.05";
    ml-pkgs.inputs.nixpkgs.follows = "nixpkgs";
    ml-pkgs.inputs.utils.follows = "utils";

    tensor-splines.url = "git+ssh://git@github.com/HorizonRobotics/tensor-splines?ref=main";
    tensor-splines.inputs.nixpkgs.follows = "nixpkgs";
    tensor-splines.inputs.utils.follows = "utils";
    tensor-splines.inputs.ml-pkgs.follows = "ml-pkgs";

    alf.url = "github:HorizonRobotics/alf/PR/breakds/alf_packaged";
    alf.inputs.nixpkgs.follows = "nixpkgs";

    unitree-go1-sdk.url = "git+ssh://git@github.com/HorizonRoboticsInternal/unitree-go1-sdk";
    unitree-go1-sdk.inputs.nixpkgs.follows = "nixpkgs";

    sagittarius-sdk.url = "git+ssh://git@github.com/HorizonRoboticsInternal/sagittarius-sdk";
    sagittarius-sdk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    overlays = {
      extra = import ./nix/overlays/extra.nix;
      default = nixpkgs.lib.composeManyExtensions [
        inputs.ml-pkgs.overlays.torch-family
        inputs.ml-pkgs.overlays.simulators
        inputs.tensor-splines.overlays.default
        self.overlays.extra
      ];
      hobot = nixpkgs.lib.composeManyExtensions [
        inputs.ml-pkgs.overlays.math
        self.overlays.default
        inputs.alf.overlays.default
        inputs.unitree-go1-sdk.overlays.default
        inputs.sagittarius-sdk.overlays.default
      ];
    };
  } // inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system:
    let pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
            cudaCapabilities = [ "7.5" "8.6" ];
            cudaForwardCompat = false;
          };
          overlays = [ self.overlays.default ];
        };
    in {
      devShells = {
        default = pkgs.callPackage ./nix/pkgs/alf-dev-shell {};
        openai-ppg-dev = pkgs.callPackage ./nix/pkgs/openai-ppg-devenv {};
        hobot-dev = let pkgs' = import nixpkgs {
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
        }; in pkgs'.callPackage ./nix/pkgs/hobot-dev-shell {
          useLegacyMujoco = true;
        };
      };
    });
}

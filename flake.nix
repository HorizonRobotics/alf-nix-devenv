
{
  description = "Agent Learning Framework Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    utils.url = "github:numtide/flake-utils";

    ml-pkgs.url = "github:nixvital/ml-pkgs";
    ml-pkgs.inputs.nixpkgs.follows = "nixpkgs";
    ml-pkgs.inputs.utils.follows = "utils";

    tensor-splines-flake.url = "git+ssh://git@github.com/HorizonRobotics/tensor-splines?ref=main";
    tensor-splines-flake.inputs.nixpkgs.follows = "nixpkgs";
    tensor-splines-flake.inputs.utils.follows = "utils";
  };

  outputs = { self, nixpkgs, ml-pkgs, ... }@inputs: inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system:
    let pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            ml-pkgs.overlays.torch-family
            ml-pkgs.overlays.simulators
            # Use this overlay to provide customized python packages
            # for development environment.
            (import ./nix/overlays/dev.nix {
              tensor-splines = inputs.tensor-splines-flake.packages."${system}".default;
            })
          ];
        };
    in {
      devShells = {
        default = pkgs.callPackage ./nix/pkgs/alf-dev-shell {};
        openai-ppg-dev = pkgs.callPackage ./nix/pkgs/openai-ppg-devenv {};
      };
    });
}

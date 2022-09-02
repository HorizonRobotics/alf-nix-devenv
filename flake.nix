
{
  description = "Agent Learning Framework Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    utils.url = "github:numtide/flake-utils";
    utils.inputs.nixpkgs.follows = "nixpkgs";

    ml-pkgs.url = "github:nixvital/ml-pkgs/dev/alf/22.05";
    ml-pkgs.inputs.nixpkgs.follows = "nixpkgs";
    ml-pkgs.inputs.utils.follows = "utils";

    tensor-splines-flake.url = "git+ssh://git@github.com/HorizonRobotics/tensor-splines?ref=main";
    tensor-splines-flake.inputs.nixpkgs.follows = "nixpkgs";
    tensor-splines-flake.inputs.utils.follows = "utils";
  };

  outputs = { self, nixpkgs, ... }@inputs: inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system:
    let pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            # Use this overlay to provide customized python packages
            # for development environment.
            (import ./nix/overlays/dev.nix {
              inherit (inputs.ml-pkgs.packages."${system}")
                pytorchWithCuda11
                procgen
                atari-py-with-rom
                pytorchvizWithCuda11
                highway-env
                metadrive-simulator
                gym
                matplotlib;
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

  

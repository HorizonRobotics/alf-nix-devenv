
{
  description = "Agent Learning Framework Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

    utils.url = "github:numtide/flake-utils";
    utils.inputs.nixpkgs.follows = "nixpkgs";

    ml-pkgs.url = "github:nixvital/ml-pkgs/dev/21.11";
    ml-pkgs.inputs.nixpkgs.follows = "nixpkgs";
    ml-pkgs.inputs.utils.follows = "utils";
  };

  outputs = { self, nixpkgs, ... }@inputs: inputs.utils.lib.eachSystem [
    "x86_64-linux" "i686-linux" "aarch64-linux" "x86_64-darwin"
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
                preferredCuda
                preferredCudnn;
            })
          ];
        };
    in {
      devShell = pkgs.callPackage ./nix/pkgs/alf-dev-shell {};
      packages = {
        openai-ppg-dev = pkgs.callPackage ./nix/pkgs/openai-ppg-devenv {};
      };
    });
}

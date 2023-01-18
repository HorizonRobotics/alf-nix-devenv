
{
  description = "Agent Learning Framework Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    utils.url = "github:numtide/flake-utils";

    ml-pkgs.url = "github:nixvital/ml-pkgs";
    ml-pkgs.inputs.nixpkgs.follows = "nixpkgs";
    ml-pkgs.inputs.utils.follows = "utils";

    tensor-splines.url = "git+ssh://git@github.com/HorizonRobotics/tensor-splines?ref=main";
    tensor-splines.inputs.nixpkgs.follows = "nixpkgs";
    tensor-splines.inputs.utils.follows = "utils";

    alf.url = "github:HorizonRobotics/alf?rev=fa6328118f8dd631325a5058f6241bfad4341e18";
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
    };
  } // inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system:
    let pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ self.overlays.default ];
        };
    in {
      devShells = {
        default = pkgs.callPackage ./nix/pkgs/alf-dev-shell {};
        openai-ppg-dev = pkgs.callPackage ./nix/pkgs/openai-ppg-devenv {};
        hobot-dev = let pkgs' = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            self.overlays.default
            inputs.alf.overlays.default
          ];
        }; in pkgs'.callPackage ./nix/pkgs/hobot-dev-shell {};
      };
    });
}

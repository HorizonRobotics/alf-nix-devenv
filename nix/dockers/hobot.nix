{ dockerTools
, mkShell
, python3
}:

let python-env = python3.withPackages (p: with p; [
      alf
      numpy
    ]);

    devShell = mkShell {
      name = "hobot";
      packages = [
        python-env
      ];
    };

in dockerTools.buildNixShellImage {
  name = "hobot-docker";
  tag = "2024.07.11";

  drv = devShell;
}

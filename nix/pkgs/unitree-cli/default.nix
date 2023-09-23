{ writers
, python3Packages }:

writers.writePython3Bin "unitree-cli" {
  libraries = with python3Packages; [
    click
    loguru
    pyunitree
  ];
} (builtins.readFile ./unitree-cli.py)

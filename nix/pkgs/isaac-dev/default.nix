# This is a development environment for Hobot

{ lib
, stdenv
, mkShell
, python38
, nodePackages
, ninja
, vulkan-headers
, vulkan-loader
, vulkan-tools
}:

mkShell {
  name = "isaac";
  packages = let pythonDevEnv = python38.withPackages (pyPkgs: with pyPkgs; [
      pytorchWithCuda11
      torchvisionWithCuda11
      isaac-gym
      pudb
  ]); in [
    pythonDevEnv
    nodePackages.pyright
    ninja
    vulkan-headers
    vulkan-loader
    vulkan-tools
  ];

  shellHook = ''
    export PS1="$(echo -e '\uf3e2') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (hobot) \\$ \[$(tput sgr0)\]"
    # Manually set where to look for libstdc++.so.6
    export LD_LIBRARY_PATH=${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH:/run/opengl-driver/lib
    export PYTHONPATH="$(pwd):$PYTHONPATH"
    export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
  '';
}

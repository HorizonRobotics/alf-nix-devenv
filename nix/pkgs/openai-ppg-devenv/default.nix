# This is a development environment for OpenAI's phasic policy
# gradient implementation.

{ mkShell
, python3
, python-language-server
, mpich
}:

let pythonForPPG = python3.withPackages (pyPkgs: with pyPkgs; [
      # For both Dev and Deploy
      pytorchWithCuda11
      numpy pandas
      gym matplotlib
      mpi4py
      procgen
    ]);

    pythonIcon = "f3e2";

in mkShell rec {
  name = "openai-ppg";

  packages = [
    pythonForPPG
    python-language-server  # From Microsoft, not Palantir
    mpich
  ];

  # This is to have a leading python icon to remind the user we are in
  # the Alf python dev environment.
  shellHook = ''
    export PS1="$(echo -e '\u${pythonIcon}') {\[$(tput sgr0)\]\[\033[38;5;228m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]} (${name}) \\$ \[$(tput sgr0)\]"
  '';
}

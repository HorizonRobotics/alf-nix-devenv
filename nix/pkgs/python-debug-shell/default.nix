{ mkShell
, python3
, enableDebugging
, runCommand
, makeWrapper
, gdb
}:

let debugpy = let
      self = enableDebugging (
        python3.overrideAttrs (old: { disallowedReferences = []; })
      );
    in python3.override { inherit self; };

    unpackSrc = drv: runCommand "${drv.name}-unpacked" { inherit (drv) src; } ''
      unpackPhase
      mv "$sourceRoot" "$out"
    '';

    gdb-py = runCommand "gdb-withpy" { buildInputs = [ makeWrapper ]; } ''
       mkdir -p "$out/bin"
       makeWrapper "${gdb}/bin/gdb" "$out/bin/gdb" \
           --add-flags '-ex "source ${unpackSrc debugpy}/Tools/gdb/libpython.py"'
    '';
in mkShell rec {
  name = "GDBPY";

  packages = [
    gdb-py
  ];
}

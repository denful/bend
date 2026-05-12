let
  # Import all .nix files from nix/ directory
  readDirImports =
    dir:
    let
      files = builtins.readDir dir;
      fileList = builtins.filter (name: builtins.match ".*\\.nix$" name != null) (
        builtins.attrNames files
      );
      imports = builtins.map (name: import (dir + "/${name}") bend) fileList;
    in
    builtins.foldl' (acc: val: acc // val) { } imports;

  bend = readDirImports ./nix // (import ./nix/functor.nix bend);
in
bend

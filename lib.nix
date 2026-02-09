# Scanne un répertoire et retourne la liste des modules à importer :
#   - fichiers .nix (sauf default.nix)
#   - sous-dossiers (importés via leur default.nix)
dir:
let
  entries = builtins.readDir dir;
  names = builtins.attrNames entries;
  hasSuffix = suffix: s:
    let
      sLen = builtins.stringLength s;
      suffLen = builtins.stringLength suffix;
    in
      sLen >= suffLen && builtins.substring (sLen - suffLen) suffLen s == suffix;
  isModule = name:
    let type = entries.${name}; in
    (type == "directory") ||
    (type == "regular" && name != "default.nix" && hasSuffix ".nix" name);
  modulePaths = builtins.filter isModule names;
in
  map (name: dir + "/${name}") modulePaths

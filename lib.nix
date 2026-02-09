# Importe tous les fichiers .nix d'un dossier (sauf default.nix).
dir:
let
  entries = builtins.readDir dir;
  isModule = name:
    entries.${name} == "regular"
    && name != "default.nix"
    && builtins.match ".*\.nix" name != null;
in
  map (name: dir + "/${name}") (builtins.filter isModule (builtins.attrNames entries))

{ lib }:
{
  # Use this type for any custom module option that accepts a path to a secret file.
  # Rejects path literals (which get copied to /nix/store) and /nix/store paths.
  # Only accepts absolute string paths like "/run/secrets/foo".
  secretPathType = lib.mkOptionType {
    name = "secretPath";
    description = "absolute path string to a secret file (NOT a path literal)";
    check =
      value:
      builtins.isString value
      && builtins.substring 0 1 value == "/"
      && !(lib.hasPrefix "/nix/store" value);
    merge = lib.mergeEqualOption;
  };
}

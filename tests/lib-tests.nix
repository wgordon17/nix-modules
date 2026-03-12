{ pkgs }:
let
  myLib = import ../lib { inherit (pkgs) lib; };
  inherit (myLib.types) secretPathType;
in
pkgs.lib.runTests {
  testSecretPathAcceptsAbsoluteString = {
    expr = secretPathType.check "/run/secrets/my-secret";
    expected = true;
  };

  testSecretPathRejectsRelativeString = {
    expr = secretPathType.check "secrets/my-secret";
    expected = false;
  };

  testSecretPathRejectsNixStorePath = {
    expr = secretPathType.check "/nix/store/abc-secret";
    expected = false;
  };

  testSecretPathRejectsNonString = {
    expr = secretPathType.check 42;
    expected = false;
  };
}

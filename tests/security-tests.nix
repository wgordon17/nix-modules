{ pkgs }:
let
  myLib = import ../lib { inherit (pkgs) lib; };
  inherit (myLib.types) secretPathType;
in
pkgs.lib.runTests {
  # Bare /nix/store (no trailing content) is also rejected
  testRejectsBareNixStorePath = {
    expr = secretPathType.check "/nix/store";
    expected = false;
  };

  # hasPrefix "/nix/store" intentionally rejects /nix/store* broadly —
  # a path like /nix/storefoo would be rejected (security-conservative)
  testRejectsNixStorePrefixFalsePositive = {
    expr = secretPathType.check "/nix/storefoo";
    expected = false;
  };

  testAcceptsSopsPath = {
    expr = secretPathType.check "/run/secrets/my-service/password";
    expected = true;
  };

  testAcceptsEtcPath = {
    expr = secretPathType.check "/etc/secrets/api-key";
    expected = true;
  };

  testRejectsEmptyString = {
    expr = secretPathType.check "";
    expected = false;
  };
}

# These predicates are duplicated from modules/common/default.nix assertions.
# Full evalModules is not possible here (requires NixOS module system for config.users.users).
# If the assertion logic in common/default.nix changes, update these predicates to match.
{ pkgs }:
let
  checkPasswordAssertion =
    users: !(builtins.any (u: u.password or null != null) (builtins.attrValues users));

  checkHashedPasswordAssertion =
    users: !(builtins.any (u: u.hashedPassword or null != null) (builtins.attrValues users));
in
pkgs.lib.runTests {
  testPasswordAssertionPassesWithNoPassword = {
    expr = checkPasswordAssertion { alice = { }; };
    expected = true;
  };

  testPasswordAssertionFailsWithPassword = {
    expr = checkPasswordAssertion {
      alice = {
        password = "bad";
      };
    };
    expected = false;
  };

  testHashedPasswordAssertionPassesWithNoHash = {
    expr = checkHashedPasswordAssertion { alice = { }; };
    expected = true;
  };

  testHashedPasswordAssertionFailsWithHash = {
    expr = checkHashedPasswordAssertion {
      alice = {
        hashedPassword = "$6$hash";
      };
    };
    expected = false;
  };
}

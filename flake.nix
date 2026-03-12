{
  description = "Reusable NixOS and nix-darwin modules, home-manager features, and lint rules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      # --- Module exports (consumed by private nix-config repo) ---

      darwinModules = {
        common = ./modules/common;
        darwin = ./modules/darwin;
      };

      nixosModules = {
        common = ./modules/common;
        nixos = ./modules/nixos;
        impermanence = ./modules/nixos/impermanence.nix;
      };

      homeManagerModules = {
        base = ./home-manager/features/base.nix;
        development = ./home-manager/features/development.nix;
        child = ./home-manager/features/child.nix;
        media = ./home-manager/features/media.nix;
      };

      # Reusable types (secretPathType, etc.)
      lib = import ./lib { inherit (nixpkgs) lib; };

      # Overlays
      overlays = import ./overlays { };

      # --- Self-contained tooling ---

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          formatting =
            pkgs.runCommand "check-formatting"
              {
                buildInputs = with pkgs; [
                  nixfmt-rfc-style
                  findutils
                ];
              }
              ''
                find ${self} -name '*.nix' -exec nixfmt --check {} +
                touch $out
              '';
          lint = pkgs.runCommand "check-lint" { buildInputs = [ pkgs.statix ]; } ''
            cd ${self}
            statix check .
            touch $out
          '';
          deadcode = pkgs.runCommand "check-deadcode" { buildInputs = [ pkgs.deadnix ]; } ''
            cd ${self}
            deadnix --fail .
            touch $out
          '';
          lib-tests =
            let
              results = import ./tests/lib-tests.nix { inherit pkgs; };
            in
            pkgs.runCommand "lib-tests" { } (
              if results == [ ] then
                "touch $out"
              else
                builtins.throw "lib-tests failed: ${builtins.toJSON results}"
            );
          module-tests =
            let
              results = import ./tests/module-tests.nix { inherit pkgs; };
            in
            pkgs.runCommand "module-tests" { } (
              if results == [ ] then
                "touch $out"
              else
                builtins.throw "module-tests failed: ${builtins.toJSON results}"
            );
          security-tests =
            let
              results = import ./tests/security-tests.nix { inherit pkgs; };
            in
            pkgs.runCommand "security-tests" { } (
              if results == [ ] then
                "touch $out"
              else
                builtins.throw "security-tests failed: ${builtins.toJSON results}"
            );
          pre-commit = self.pre-commit-hooks.${system};
        }
      );

      pre-commit-hooks = forAllSystems (
        system:
        git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            nixfmt-rfc-style.enable = true;
            statix.enable = true;
            deadnix.enable = true;
            # AST-based secrets lint (catches bad patterns even in module examples)
            nix-secrets-lint = {
              enable = true;
              name = "nix-secrets-lint";
              entry = "${
                nixpkgs.legacyPackages.${system}.ast-grep
              }/bin/ast-grep scan --config ${self}/.ast-grep/sgconfig.yml";
              types = [ "nix" ];
              pass_filenames = false;
            };
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt-rfc-style
              statix
              deadnix
              ast-grep
            ];
            inherit (self.pre-commit-hooks.${system}) shellHook;
          };
        }
      );
    };
}

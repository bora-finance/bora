{
  description = "bora";
  nixConfig.bash-prompt = "\\[\\e[0m\\][\\[\\e[0;2m\\]nix-develop \\[\\e[0;1m\\]Bora \\[\\e[0;32m\\]\\w\\[\\e[0m\\]]\\[\\e[0m\\]$ \\[\\e[0m\\]";


  inputs = {
    nixpkgs.follows = "plutip/nixpkgs";
    haskell-nix.follows = "plutip/haskell-nix";

    plutarch.url = "github:Plutonomicon/plutarch?ref=staging";

    plutarch.inputs.haskell-nix.follows = "plutip/haskell-nix";
    plutarch.inputs.nixpkgs.follows = "plutip/nixpkgs";

    plutus-apps.url = "github:input-output-hk/plutus-apps";
  };


  outputs = inputs@{ self, nixpkgs, haskell-nix, plutarch, plutip, plutus-apps, ... }:
    let
      # GENERAL
      supportedSystems = with nixpkgs.lib.systems.supported; tier1 ++ tier2 ++ tier3;
      perSystem = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [ haskell-nix.overlay (import "${plutip.inputs.iohk-nix}/overlays/crypto") ];
        inherit (haskell-nix) config;
      };
      nixpkgsFor' = system: import nixpkgs { inherit system; };

      formatCheckFor = system:
        let
          pkgs = nixpkgsFor system;
          pkgs' = nixpkgsFor' system;
        in
        pkgs.runCommand "format-check"
          {
            nativeBuildInputs = [
              pkgs'.git
              pkgs'.fd
              pkgs'.haskellPackages.cabal-fmt
              pkgs'.nixpkgs-fmt
              (pkgs.haskell-nix.tools onchain-plutarch.ghcVersion { inherit (plutarch.tools) fourmolu; }).fourmolu
            ];
          } ''
          export LC_CTYPE=C.UTF-8
          export LC_ALL=C.UTF-8
          export LANG=C.UTF-8
          cd ${self}
          make format_check
          mkdir $out
        ''
      ;

      deferPluginErrors = true;

      # Scripts

      scripts = rec {
        ghcVersion = "ghc921";

        projectFor = system:
          let pkgs = nixpkgsFor system; in
          let pkgs' = nixpkgsFor' system; in
          (nixpkgsFor system).haskell-nix.cabalProject' {
            src = ./.;
            compiler-nix-name = ghcVersion;
            cabalProjectFileName = "cabal.project.scripts";
            inherit (plutarch) cabalProjectLocal;
            extraSources = plutarch.extraSources ++ [
              {
                src = inputs.plutarch;
                subdirs = [
                  "."
                  "plutarch-extra"
                  "plutarch-test"
                ];
              }
            ];
            modules = [ (plutarch.haskellModule system) ];
            shell = {
              withHoogle = true;

              exactDeps = true;
              
              nativeBuildInputs = [
                pkgs'.cabal-install
                pkgs'.fd
                pkgs'.haskellPackages.apply-refact
                pkgs'.haskellPackages.cabal-fmt
                pkgs'.hlint
                pkgs'.nixpkgs-fmt
              ];

              inherit (plutarch) tools;

              additional = ps: [
                ps.plutarch
                ps.plutarch-extra
                ps.plutarch-test
                ps.tasty-quickcheck
              ];

              shellHook = ''
                export NIX_SHELL_TARGET="scripts"
                ln -fs cabal.project.scripts cabal.project
              '';
            };
          };
      };

      inherit nixpkgsFor;

      scripts = {
        project = perSystem scripts.projectFor;
        flake = perSystem (system: (onchain-plutarch.projectFor system).flake { });
      };

      packages = perSystem (system:
        self.scripts.flake.${system}.packages
      );
      checks = perSystem (system:
        self.scripts.flake.${system}.checks
          formatCheck = formatCheckFor system;
        }
      );
      check = perSystem (system:
        (nixpkgsFor system).runCommand "combined-test"
          {
            checksss =
              builtins.attrValues self.checks.${system}
              ++ builtins.attrValues self.packages.${system}
              ++ [
                self.devShells.${system}.scripts.inputDerivation
              ];
          } ''
          echo $checksss
          touch $out
        ''
      );

      devShells = perSystem (system: {
        scripts = self.onchain-plutarch.flake.${system}.devShell;
      });
    };
}

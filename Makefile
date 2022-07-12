
hoogle: requires_nix_shell
	hoogle server --local --port=8070 > /dev/null &

build: requires_nix_shell
	cabal v2-build $(GHC_FLAGS) all

test: requires_nix_shell
	cabal v2-test all

ghci_scripts: requires_nix_shell
	cabal v2-repl $(GHC_FLAGS) bora-scripts:bora-scripts

# Run fourmolu formatter
format: requires_nix_shell
	env -C scripts fourmolu --mode inplace --check-idempotence -e $(shell env -C scripts fd -ehs)
	nixpkgs-fmt $(NIX_SOURCES)
	cabal-fmt -i $(CABAL_SOURCES)

# Check formatting (without making changes)
format_check:
	env -C scripts fourmolu --stdin-input-file . --mode check --check-idempotence -e $(shell env -C scripts fd -ehs)
	nixpkgs-fmt --check $(NIX_SOURCES)
	cabal-fmt -c $(CABAL_SOURCES)

FORMAT_EXTENSIONS := -o -XTemplateHaskell -o -XTypeApplications -o -XImportQualifiedPost -o -XPatternSynonyms -o -fplugin=RecordDotPreprocessor

NIX_SHELL_SCRIPTS = nix develop .\#scripts
HLS_SHELL_SCRIPTS = $(NIX_SHELL_SCRIPTS) -c nix-shell -p bashInteractive haskell-language-server

script_shell:
	$(NIX_SHELL_SCRIPTS)

script_code:
	$(HLS_SHELL_SCRIPTS) --run "code ."

# Nix files to format
NIX_SOURCES := $(shell fd -enix)
CABAL_SOURCES := $(shell fd -ecabal)

# Apply hlint suggestions
lint: requires_nix_shell
	find -name '*.hs' -not -path './dist-*/*' -exec hlint --refactor --refactor-options="--inplace" {} \;

# Check hlint suggestions
lint_check: requires_nix_shell
	hlint $(shell fd -ehs)

# Target to use as dependency to fail if not inside nix-shell
requires_nix_shell:
	@ [ "$(IN_NIX_SHELL)" ] || echo "The $(MAKECMDGOALS) target must be run from inside a nix shell"
	@ [ "$(IN_NIX_SHELL)" ] || (echo "    run 'nix develop' first" && false)

################################################################################
# Utils

build_path = dist-newstyle/build/x86_64-linux/ghc-8.10.4.20210212/vulcan-smart-contracts-0.1
clear_build:
	@[ ! -e $(build_path) ] || rm -rf $(build_path)



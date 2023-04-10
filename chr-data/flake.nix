{

  description = ''
    chr: Constraint Handling Rules library
  '';

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/master"; };
  outputs = inputs@{ self, nixpkgs }:
    let
      homepage = "https://github.com/atzedijkstra/chr";
      license = nixpkgs.lib.licenses.bsd3;
      description = ''
        chr: Constraint Handling Rules library.
      '';
      # GENERAL
      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      perSystem = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = system: nixpkgs.legacyPackages.${system};

      mkDevEnv = system:
        let pkgs = nixpkgsFor system;
        in pkgs.stdenv.mkDerivation {
          name = "Standard-Dev-Environment-with-Utils";
          buildInputs = (with pkgs; [ ]);
        };

      haskell = rec {
        projectFor = system:
          let
            pkgs = nixpkgsFor system;
            stdDevEnv = mkDevEnv system;
            haskell-pkgs = pkgs.haskell.packages.ghc927;

            project = haskell-pkgs.developPackage {
              name = "chr-data";
              root = ./.;
              modifier = drv:
                pkgs.haskell.lib.addBuildTools drv (stdDevEnv.buildInputs);
            };

          in project;
      };

    in {
      haskell = perSystem (system: (haskell.projectFor system));

      devShells = perSystem (system: {
        # Enter shell by "nix develop"
        default = let project = self.haskell.${system};
        in project.env.overrideAttrs (oldAttrs: {
          shellHook = ''
            ${oldAttrs.shellHook}
            export PATH=$PATH:${project}/bin
          '';
        });
      });

      # To be executed by"nix build"
      packages = perSystem (system: { default = self.haskell.${system}; });

    };
}

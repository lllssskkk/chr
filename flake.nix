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
            haskell-pkgs = pkgs.haskellPackages;

            project = pkgs.haskellPackages.extend
              (pkgs.haskell.lib.packageSourceOverrides {
                chr-core = haskell-pkgs.developPackage {
                  name = "chr-core";
                  root = ./chr-core/.;
                  overrides = self: super: { chr-data = project.chr-data; };
                  modifier = drv:
                    pkgs.haskell.lib.addBuildTools drv (stdDevEnv.buildInputs);
                };
                chr-data = haskell-pkgs.developPackage {
                  name = "chr-data";
                  root = ./chr-data/.;
                  modifier = drv:
                    pkgs.haskell.lib.addBuildTools drv (stdDevEnv.buildInputs);
                };
                chr-pretty = haskell-pkgs.developPackage {
                  name = "chr-pretty";
                  root = ./chr-pretty/.;
                  modifier = drv:
                    pkgs.haskell.lib.addBuildTools drv (stdDevEnv.buildInputs);
                };
                chr-lang = haskell-pkgs.developPackage {
                  name = "chr-lang";
                  root = ./chr-lang/.;
                  modifier = drv:
                    pkgs.haskell.lib.addBuildTools drv (stdDevEnv.buildInputs);
                };
                chr-parse = haskell-pkgs.developPackage {
                  name = "chr-parse";
                  root = ./chr-parse/.;
                  modifier = drv:
                    pkgs.haskell.lib.addBuildTools drv (stdDevEnv.buildInputs);
                };
              });
          in project;
      };

    in {
      haskell = perSystem (system: (haskell.projectFor system));

      chr-core = perSystem (system: self.haskell.${system}.chr-core);
      chr-data = perSystem (system: self.haskell.${system}.chr-data);
      chr-pretty = perSystem (system: self.haskell.${system}.chr-pretty);
      chr-lang = perSystem (system: self.haskell.${system}.chr-lang);
      chr-parse = perSystem (system: self.haskell.${system}.chr-parse);

      # To be executed by"nix build"
      # packages =
      #   perSystem (system: { default = self.haskell.${system}.chr-core; });

    };
}

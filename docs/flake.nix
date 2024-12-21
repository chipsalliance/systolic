{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgName = "matmul-spec";
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        packages = {
          ${pkgName} = pkgs.stdenv.mkDerivation {
            pname = pkgName;
            version = "1.0.0";
            src = ./en;
            buildInputs = [
              pkgs.typst
              pkgs.sarasa-gothic
            ];

            buildPhase = ''
              typst compile main.typ "matmul_spec_en.pdf"
            '';

            installPhase = ''
              mkdir -p "$out"
              cp matmul_spec_en.pdf "$out"
            '';
          };
        };

        formatter = pkgs.nixfmt-rfc-style;

        devShells = {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.${pkgName} ];
            nativeBuildInputs = with pkgs; [
              git
            ];
          };
        };

        defaultPackage = flake-utils.lib.eachDefaultSystem (system: self.packages.${system}.${pkgName});
      }
    );
}

{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgName = "matmul-spec";
        pkgs = import nixpkgs { inherit system; };
      in {
        packages = {
          ${pkgName} = pkgs.stdenv.mkDerivation {
            pname = pkgName;
            version = "1.0.0";
            src = ./en;
            buildInputs = [
              pkgs.typst
              pkgs.pandoc
              pkgs.sarasa-gothic
              pkgs.noto-fonts
              pkgs.fontconfig
            ];

            buildPhase = ''
              font_dirs=(
                "${pkgs.sarasa-gothic}/share/fonts/truetype"
                "${pkgs.noto-fonts}/share/fonts"
                # Add more font directories here...
              )
              # Create custom fontconfig configuration
              mkdir -p fontconfig/conf.d
              cat > fontconfig/conf.d/99-custom-fonts.conf << EOF
              <?xml version="1.0"?>
              <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
              <fontconfig>
                <!-- Add your font directories and set high priority -->
                <dir>${pkgs.sarasa-gothic}/share/fonts/truetype</dir>
                <dir>${pkgs.noto-fonts}/share/fonts</dir>
                <!-- Set font priorities -->
                <alias binding="strong">
                  <family>sans-serif</family>
                  <prefer>
                    <family>Sarasa Gothic</family>
                    <family>Noto Sans</family>
                  </prefer>
                </alias>
              </fontconfig>
              EOF
              # Use custom configuration
              export FONTCONFIG_FILE=$(pwd)/fontconfig/conf.d/99-custom-fonts.conf
              export FONTCONFIG_PATH=${pkgs.fontconfig.out}/etc/fonts
              for md in *.md; do
                if [ -f "$md" ]; then
                  typ_file="$md.typ"
                  pandoc "$md" -f markdown -t typst -o "$typ_file"
                fi
              done
              export FILE_NAME=$(echo "${pkgName}" | sed 's/-/_/g')_$(basename "$src" | sed 's/^.*-//').pdf
              typst compile main.typ "$FILE_NAME"
            '';

            installPhase = ''
              mkdir -p "$out"
              cp "$FILE_NAME" "$out"
            '';
          };
        };

        formatter = pkgs.nixfmt-rfc-style;

        devShells = {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.${pkgName} ];
            nativeBuildInputs = with pkgs; [ git ];
            shellHook = ''
              export FONTCONFIG_PATH="${pkgs.fontconfig.out}/etc/fonts"
            '';
          };
        };

        defaultPackage = flake-utils.lib.eachDefaultSystem
          (system: self.packages.${system}.${pkgName});
      });
}

{
  description =
    "LivingPath - Algorithmic font modification software (otf & ttf)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    tkdnd = {
      url = "github:bluelinden/tkdnd";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, tkdnd }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ tkdnd.overlays.default ];
        };

        python = pkgs.python313;

        # tkinterdnd2 - drag and drop for tkinter
        tkinterdnd2 = python.pkgs.buildPythonPackage rec {
          pname = "tkinterdnd2";
          version = "0.4.2";
          format = "setuptools";

          src = python.pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-ABgKw42GV4RB3qRmICbHhnoCLhRQGtSS+B4i4iE1zrY=";
          };

          nativeBuildInputs = [ pkgs.tk ];
          buildInputs = [ pkgs.tk pkgs.tcl ];
          propagatedBuildInputs = with python.pkgs; [ tkinter ];

          # Skip import check as it requires display
          pythonImportsCheck = [ ];
          doCheck = false;
        };

        potracer = python.pkgs.buildPythonPackage rec {
          pname = "potracer";
          version = "0.0.4";
          format = "setuptools";

          src = pkgs.fetchFromGitHub {
            owner = "tatarize";
            repo = "potrace";
            rev = "769eadc85ab2ae6c3334686eaab0296fdfdf6abc";
            hash =
              "sha256-OzEFbbbm6qDn80UeNQWLHoQ3pfDgTPhbvLpk8ekUuDw=";
          };

          propagatedBuildInputs = with python.pkgs; [ numpy ];

          # Optional CLI dependency (potrace-cli) can be added if needed
          # passthru.optional-dependencies. cli = [ potrace-cli ];

          pythonImportsCheck = [ "potrace" ];
        };

        # tkhtmlview - HTML rendering in tkinter
        tkhtmlview = python.pkgs.buildPythonPackage rec {
          pname = "tkhtmlview";
          version = "0.3.0";
          format = "pyproject";

          src = python.pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-ezWZlx7TMRzP9BYz+OFSkxNi98bHnOfy9bYqRIA4M4E=";
          };

          nativeBuildInputs = with python.pkgs; [ poetry-core ];

          propagatedBuildInputs = with python.pkgs; [ pillow requests tkinter ];

          # Skip import check as it requires display
          pythonImportsCheck = [ ];
          pythonRelaxDeps = [ "pillow" ];
          doCheck = false;
        };

        # seam-carving
        seam-carving = python.pkgs.buildPythonPackage rec {
          pname = "seam-carving";
          version = "1.1.0";
          format = "wheel";

          src = pkgs.fetchurl {
            url =
              "https://files.pythonhosted.org/packages/e4/ad/ecfbde3720752af1f2e4884beff0f21113f25803162fcd45612ef64e8dd7/seam_carving-1.1.0-py3-none-any.whl";
            hash = "sha256-F4Y34GBQCyZ+/2UdsN8RsUTribJPgijBBdW2ZGE1c+Q=";
          };

          propagatedBuildInputs = with python.pkgs; [ numpy scipy numba ];

          pythonImportsCheck = [ "seam_carving" ];
          doCheck = false;
        };

        # playsound3
        playsound3 = python.pkgs.buildPythonPackage rec {
          pname = "playsound3";
          version = "2.5.2";
          format = "pyproject";

          src = python.pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-N+ddmAPK5YAeOnwWv2yHFcP0ht82N+VQyccp5URlLMw=";
          };

          nativeBuildInputs = with python.pkgs; [ hatchling certifi ];

          propagatedBuildInputs = [ pkgs.alsa-lib pkgs.ffmpeg ]
            ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.pulseaudio ];

          # Skip import check as it requires audio backend at import time
          pythonImportsCheck = [ ];
          doCheck = false;
        };

        # perlin-numpy
        perlin-numpy = python.pkgs.buildPythonPackage rec {
          pname = "perlin-numpy";
          version = "0.0.1";
          format = "setuptools";

          src = pkgs.fetchFromGitHub {
            owner = "pvigier";
            repo = "perlin-numpy";
            rev = "5e26837db14042e51166eb6cad4c0df2c1907016";
            hash = "sha256-RPBCpD7wUuTSu2WyhOAvOBoK1i0qaDLqn1gdNMYgmoE=";
          };

          nativeBuildInputs = with python.pkgs; [ setuptools ];

          propagatedBuildInputs = with python.pkgs; [ numpy ];

          doCheck = false;
        };

        # hyperglot - font language support checker
        hyperglot = python.pkgs.buildPythonPackage rec {
          pname = "hyperglot";
          version = "0.7.2";
          format = "pyproject";

          src = python.pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-/3zg/CsX0r5w7MyIkxCN40TYukmm9u0xJQJCeKrDHT0=";
          };

          nativeBuildInputs = with python.pkgs; [
            setuptools
            setuptools-scm
            uharfbuzz
            colorlog
          ];

          propagatedBuildInputs = with python.pkgs; [ fonttools pyyaml click ];

          pythonImportsCheck = [ "hyperglot" ];
          doCheck = false;
        };

        pythonDeps = with python.pkgs; [
          # Font tools
          fonttools
          brotli
          cffsubr
          uharfbuzz
          freetype-py
          skia-pathops

          # Image processing
          pillow
          opencv4
          numpy
          scipy
          scikit-image
          numba
          matplotlib

          # Physics simulation
          pymunk

          # Other dependencies
          beziers
          python-iso639
          wikipedia-api

          # Custom packages
          tkinterdnd2
          potracer
          tkhtmlview
          seam-carving
          playsound3
          perlin-numpy
          hyperglot
        ];

        livingpath = python.pkgs.buildPythonApplication {
          pname = "livingpath";
          version = "1.0.0";

          src = ./.;

          format = "other";

          nativeBuildInputs = [ pkgs.makeWrapper ];

          buildInputs = [
            pkgs.tk
            pkgs.tcl
            pkgs.tkdnd
            pkgs.xorg.libX11
            pkgs.xorg.libXext
            pkgs.xorg.libXrender
          ];

          propagatedBuildInputs = pythonDeps;

          installPhase = ''
                        runHook preInstall

                        mkdir -p $out/lib/livingpath
                        mkdir -p $out/bin
                        mkdir -p $out/share/applications
                        mkdir -p $out/share/icons/hicolor/256x256/apps

                        # Copy all source files
                        cp -r *.py $out/lib/livingpath/
                        cp -r plugins $out/lib/livingpath/
                        cp -r files $out/lib/livingpath/
                        cp -r hooks $out/lib/livingpath/ 2>/dev/null || true

                        # Copy icon
                        cp files/logo.png $out/share/icons/hicolor/256x256/apps/livingpath.png

                        # Create wrapper script
                        makeWrapper ${python.interpreter} $out/bin/livingpath \
                          --prefix PYTHONPATH : "$out/lib/livingpath:${
                            python.pkgs.makePythonPath pythonDeps
                          }" \
                          --prefix PATH : "${
                            pkgs.lib.makeBinPath [ pkgs.potrace pkgs.autotrace ]
                          }" \
                          --prefix LD_LIBRARY_PATH : "${
                            pkgs.lib.makeLibraryPath [
                              pkgs.tk
                              pkgs.tcl
                              pkgs.tkdnd
                            ]
                          }" \
                          --set TCLLIBPATH "${pkgs.tkdnd}/lib" \
                          --set TK_LIBRARY "${pkgs.tk}/lib/${pkgs.tk.libPrefix}" \
                          --set TCL_LIBRARY "${pkgs.tcl}/lib/${pkgs.tcl.libPrefix}" \
                          --add-flags "-c 'import os; os.chdir(\"$out/lib/livingpath\"); exec(open(\"main.py\").read())'"

                        # Create desktop entry
                        cat > $out/share/applications/livingpath.desktop << EOF
            [Desktop Entry]
            Name=LivingPath
            Comment=Algorithmic font modification software
            Exec=$out/bin/livingpath
            Icon=livingpath
            Terminal=false
            Type=Application
            Categories=Graphics;Publishing;
            EOF

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Algorithmic font modification software (otf & ttf)";
            homepage = "http://livingpath.fr";
            license = licenses.gpl3;
            platforms = platforms.linux;
            maintainers = [ ];
          };
        };

      in {
        packages = {
          default = livingpath;
          livingpath = livingpath;
        };

        apps.default = {
          type = "app";
          program = "${livingpath}/bin/livingpath";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            python
            pkgs.tk
            pkgs.tcl
            pkgs.tkdnd
            pkgs.potrace
            pkgs.autotrace
            pkgs.xorg.libX11
            pkgs.xorg.libXext
          ] ++ pythonDeps;

          shellHook = ''
            export TCLLIBPATH="${pkgs.tkdnd}/lib"
            export TK_LIBRARY="${pkgs.tk}/lib/${pkgs.tk.libPrefix}"
            export TCL_LIBRARY="${pkgs.tcl}/lib/${pkgs.tcl.libPrefix}"
            export LD_LIBRARY_PATH="${
              pkgs.lib.makeLibraryPath [ pkgs.tk pkgs.tcl pkgs.tkdnd ]
            }:$LD_LIBRARY_PATH"
            echo "LivingPath development environment"
            echo "Run: python main.py"
          '';
        };
      });
}

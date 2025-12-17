# Development shell for LivingPath
# Usage: nix-shell
{ pkgs ? import <nixpkgs> { } }:

let
  python = pkgs.python311;

  # tkinterdnd2 - drag and drop for tkinter
  tkinterdnd2 = python.pkgs.buildPythonPackage rec {
    pname = "tkinterdnd2";
    version = "0.4.2";
    format = "setuptools";

    src = python.pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-CLLyvfpytMyyIlOEhLKvaXB2bfpdMnQafmBB16IcdxY=";
    };

    nativeBuildInputs = [ pkgs.tk ];
    buildInputs = [ pkgs.tk pkgs.tcl ];
    propagatedBuildInputs = [ pkgs.tk ];

    pythonImportsCheck = [ "tkinterdnd2" ];
    doCheck = false;
  };

  # potracer - Python binding for potrace
  potracer = python.pkgs.buildPythonPackage rec {
    pname = "potracer";
    version = "0.0.4";
    format = "setuptools";

    src = python.pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-wCF/VkN6XShLMC/6UU1rr5F/eBPoG94VrL3SQBzXv6k=";
    };

    nativeBuildInputs = [ pkgs.potrace ];
    buildInputs = [ pkgs.potrace ];

    pythonImportsCheck = [ "potracer" ];
    doCheck = false;
  };

  # tkhtmlview - HTML rendering in tkinter
  tkhtmlview = python.pkgs.buildPythonPackage rec {
    pname = "tkhtmlview";
    version = "0.3.0";
    format = "setuptools";

    src = python.pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-kBt0i7YSH5cMsIxXYuoywfSblFKgrDhAj/xWn5xnkWs=";
    };

    propagatedBuildInputs = with python.pkgs; [ pillow ];

    pythonImportsCheck = [ "tkhtmlview" ];
    doCheck = false;
  };

  # seam-carving
  seam-carving = python.pkgs.buildPythonPackage rec {
    pname = "seam-carving";
    version = "1.1.0";
    format = "setuptools";

    src = python.pkgs.fetchPypi {
      pname = "seam_carving";
      inherit version;
      hash = "sha256-YJYaXn1mJb9TXKGs3hzVoH0KIaCLJ/V0Bpop1AqVYpA=";
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
      hash = "sha256-7jMu1FVlJPCaPV02t9NeDNLR+D20hIw4NHUUaGMq6VA=";
    };

    nativeBuildInputs = with python.pkgs; [ setuptools wheel ];

    propagatedBuildInputs = [ pkgs.alsa-lib ]
      ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.pulseaudio ];

    pythonImportsCheck = [ "playsound3" ];
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
      rev = "5e26837db14042e16526d5a7c5497bad5911efed";
      hash = "sha256-iWZ7b+mjMlXvFBlWCFSjfPwE7BKEX41hF6f1uxSTmFg=";
    };

    propagatedBuildInputs = with python.pkgs; [ numpy ];

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
    hyperglot
    python-iso639
    wikipedia

    # Custom packages
    tkinterdnd2
    potracer
    tkhtmlview
    seam-carving
    playsound3
    perlin-numpy
  ];

in pkgs.mkShell {
  name = "livingpath-dev";

  buildInputs = [
    (python.withPackages (ps: pythonDeps))
    pkgs.tk
    pkgs.tcl
    pkgs.tkdnd
    pkgs.potrace
    pkgs.autotrace
    pkgs.xorg.libX11
    pkgs.xorg.libXext
    pkgs.xorg.libXrender
  ];

  shellHook = ''
    export TCLLIBPATH="${pkgs.tkdnd}/lib"
    export TK_LIBRARY="${pkgs.tk}/lib/${pkgs.tk.libPrefix}"
    export TCL_LIBRARY="${pkgs.tcl}/lib/${pkgs.tcl.libPrefix}"
    export LD_LIBRARY_PATH="${
      pkgs.lib.makeLibraryPath [ pkgs.tk pkgs.tcl pkgs.tkdnd ]
    }:$LD_LIBRARY_PATH"

    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           LivingPath Development Environment                 ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  Algorithmic font modification software (otf & ttf)          ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  Run the application:  python main.py                        ║"
    echo "║  Build package:        nix-build                             ║"
    echo "║  Use flake:            nix build .#livingpath                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
  '';
}

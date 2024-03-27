{
  description = "Beancount development environment";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
          myPython = pkgs.python311.withPackages (python-pkgs: with python-pkgs;
          [
            pytest
          ]);
          # Bazel doesn't like NixOS, so build an FHS environment with required packages
          fhs = pkgs.buildFHSUserEnv {
            name = "fhs-shell";
            targetPkgs = pkgs:
              with pkgs;
              [
                bazel
                gcc
                myPython
                pylint
              ];
            profile = ''
              export PYTHON_BIN_PATH=${myPython}/bin/python
              export PYTHON_LIB_PATH=${myPython}/lib/python3.11
            '';
          };
        in
        {
          devShells.default = fhs.env;
        }
      );
}

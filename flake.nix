{
  description = "enchiridion dev shell";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } {
            packages = with pkgs; [
              llvmPackages.libcxx
              llvmPackages.llvm
              pkg-config
              autoconf
              openssl
              libffi
              clang
              opam
              dune
              gmp
            ];

            shellHook = ''
              export CC=${pkgs.clang}/bin/clang
              export CXX=${pkgs.clang}/bin/clang++
              export CFLAGS="-Wno-error=int-conversion -Wno-error=incompatible-pointer-types"

              if [ -z "$LIBRARY_PATH" ]; then
                export LIBRARY_PATH=${pkgs.llvmPackages.libcxx}/lib
              else
                export LIBRARY_PATH=${pkgs.llvmPackages.libcxx}/lib:$LIBRARY_PATH
              fi

              export AR=${pkgs.llvmPackages.llvm}/bin/llvm-ar
              export NM=${pkgs.llvmPackages.llvm}/bin/llvm-nm
              export RANLIB=${pkgs.llvmPackages.llvm}/bin/llvm-ranlib

              if [ ! -d "$HOME/.opam" ]; then
                opam init --bare --no-setup -y
              fi
            '';
          };
        }
      );
    };
}

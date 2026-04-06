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

          wrapCC =
            name: target:
            pkgs.writeShellScriptBin name ''
              is_cxx=0
              for arg in "$@"; do
                case "$arg" in
                  *.cc|*.cpp|*.cxx|-xc++|-std=c++*) is_cxx=1; break ;;
                esac
              done
              if [ "$is_cxx" -eq 1 ]; then
                exec ${target} "$@" -std=c++14
              else
                exec ${target} "$@"
              fi
            '';

          wrapCXX =
            name: target:
            pkgs.writeShellScriptBin name ''
              exec ${target} "$@" -std=c++14
            '';
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              (wrapCC "clang" "${pkgs.stdenv.cc}/bin/clang")
              (wrapCC "cc" "${pkgs.stdenv.cc}/bin/clang")
              (wrapCC "gcc" "${pkgs.stdenv.cc}/bin/clang")
              (wrapCXX "clang++" "${pkgs.stdenv.cc}/bin/clang++")
              (wrapCXX "c++" "${pkgs.stdenv.cc}/bin/clang++")
              (wrapCXX "g++" "${pkgs.stdenv.cc}/bin/clang++")

              pkg-config
              autoconf
              openssl
              libffi
              opam
              gmp
            ];

            NIX_CFLAGS_COMPILE = "-Wno-error=int-conversion -Wno-error=incompatible-pointer-types";
            NIX_LDFLAGS = pkgs.lib.optionalString pkgs.stdenv.isDarwin "-lc++";

            shellHook = ''
              if [ ! -d "$HOME/.opam" ]; then
                opam init --bare --no-setup -y
              fi
            '';
          };
        }
      );
    };
}

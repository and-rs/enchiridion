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
              pkg-config
              openssl
              libffi
              ocaml
              opam
              just
              gmp
            ];

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

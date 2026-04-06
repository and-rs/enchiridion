switch := "5.2.0+ox"

switch-create:
    opam switch create {{switch}} --repos ox=git+https://github.com/oxcaml/opam-repository.git,default

switch-remove:
    opam switch remove {{switch}} --yes

install:
    opam install . --deps-only --with-dev-setup -y

listen:
    dune build -w

build:
    dune build

[positional-arguments]
run *args:
    #!/usr/bin/env bash
    dune exec enchiridion -- "$@"

clean:
    dune clean

fmt:
    ocamlformat --inplace $(find . -name '*.ml' -o -name '*.mli' | grep -v _build)

setup: switch-create install build

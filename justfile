switch := "5.4.1"

switch-create:
    opam switch create {{switch}} ocaml-system --repos default

switch-remove:
    opam switch remove {{switch}} --yes

install:
    opam install . --deps-only --with-dev-setup -y

listen:
    dune build -w

build:
    dune build

test:
    dune test

# Pass the test name
[positional-arguments]
stest *args:
    #!/usr/bin/env bash
    dune test -- "$@"

[positional-arguments]
run *args:
    #!/usr/bin/env bash
    dune exec enchiridion -- "$@"

clean:
    dune clean

fmt:
    ocamlformat --inplace $(find . -name '*.ml' -o -name '*.mli' | grep -v _build)

setup: switch-create install build

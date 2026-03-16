(lang dune 3.20)

(name exa-ocaml-search)

(generate_opam_files true)

(source
 (github and-rs/exa-ocaml-search))

(authors "Juan Bautista <deserd@protonmail.com>")

(license MIT)

(package
 (name exa-ocaml-search)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml core base utop cmdliner)
 (tags
  ("add topics" "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html

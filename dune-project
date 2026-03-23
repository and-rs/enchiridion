(lang dune 3.20)

(name exa-ocaml-search)

(generate_opam_files true)

(source
 (github and-rs/exa-ocaml-search))

(authors "Juan Bautista <deserd@protonmail.com>")

(maintainers "Juan Bautista <deserd@protonmail.com>")

(license MIT)

(package
 (name exa-ocaml-search)
 (synopsis "CLI search tool powered by the Exa API")
 (description
  "A command-line utility for searching the web using the Exa API. Accepts query strings via -q flag, authenticates with API key from .env, and returns formatted search results.")
 (depends ocaml async_ssl yojson cohttp-async)
 (tags
  ("cli" "search" "exa" "api" "async")))

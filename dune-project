(lang dune 3.20)

(name enchiridion)

(generate_opam_files true)

(source
 (github and-rs/enchiridion))

(authors "Juan Bautista <deserd@protonmail.com>")

(maintainers "Juan Bautista <deserd@protonmail.com>")

(license MIT)

(package
 (name enchiridion)
 (synopsis "Unix-style AI orchestrator and terminal dataflow pipeline")
 (description
  "Enchiridion is a pure Unix dataflow CLI for interacting with LLMs. It parses plain-text Markdown session files, streams Server-Sent Events (SSE) directly to stdout, and dynamically augments context using the Exa search API. Designed strictly for editor integration and terminal command generation.")
 (depends
  (ocaml
   (>= "5.4.1"))
  (dune
   (>= "3.20.0"))
  cohttp-eio
  eio_main
  ca-certs
  tls-eio
  yojson
  core
  core_unix
  mirage-crypto-rng-eio
  (utop
   (and
    :with-dev-setup
    (>= "2.16.0")))
  (ocamlformat
   (and
    :with-dev-setup
    (= "0.28.1")))
  (ocaml-lsp-server
   (and
    :with-dev-setup
    (>= "1.25.0"))))
 (tags
  ("cli" "ai" "llm" "exa" "search" "async")))

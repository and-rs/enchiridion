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
 (depends ocaml async_ssl yojson cohttp-async
  (dune             (and :with-dev-setup (= "3.21.0+ox")))
  (ocamlformat      (and :with-dev-setup (= "0.26.2+ox")))
  (ocaml-lsp-server (and :with-dev-setup (= "1.19.0+ox"))))
 (tags
  ("cli" "ai" "llm" "exa" "search" "async")))

open Core
open Tools

let https =
  let authenticator =
    match Ca_certs.authenticator () with
    | Ok a -> a
    | Error (`Msg e) -> failwith ("TLS Authenticator failed: " ^ e)
  in
  let tls_config =
    match Tls.Config.client ~authenticator () with
    | Ok c -> c
    | Error (`Msg e) -> failwith ("TLS Config failed: " ^ e)
  in
  Some
    (fun uri sock ->
      let host =
        match Uri.host uri with
        | None -> None
        | Some x -> Some Domain_name.(host_exn (of_string_exn x))
      in
      Tls_eio.client_of_flow ?host tls_config sock)

let command =
  Command.basic
    ~summary:"Enchiridion: Unix-style AI orchestrator and dataflow pipeline"
    ~readme:(fun () ->
      "Executes LLM prompts via the OpenAI API schema, processing \
       Markdown-based session files and streaming SSE responses to stdout. \
       Supports context augmentation via Exa Search. Requires relevant API \
       keys in the environment.")
    Command.Param.(
      return (fun query test () ->
          Mirage_crypto_rng_unix.use_default ();
          Eio_main.run @@ fun env ->
          Eio.Switch.run @@ fun sw ->
          let client = Cohttp_eio.Client.make ~https (Eio.Stdenv.net env) in
          let fs = Eio.Stdenv.fs env in
          Exasearch.request_handler ~sw ~fs client query test)
      <*> flag "-q" (required string)
            ~doc:"Query; Query for the semantic search"
      <*> flag "--test" no_arg
            ~doc:
              "Testing; Caches the search result in test.json to explore \
               format & state better")

let () = Command_unix.run ~version:"v0.0.1" ~build_info:"dev" command

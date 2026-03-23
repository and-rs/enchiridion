open Async
open Cohttp
open Cohttp_async

let query_flag =
  let open Command.Param in
  flag "-q" (required string) ~doc:"Pass a search query"

let exa_search (query : string) (key : string) =
  let init_headers = Header.init_with "Content-Type" "application/json" in
  let headers = Header.add init_headers "x-api-key" key in
  let body =
    Cohttp_async.Body.of_string
      (Yojson.Safe.to_string
         (`Assoc
            [
              ("query", `String query);
              ("type", `String "auto");
              ( "contents",
                `Assoc
                  [ ("highlights", `Assoc [ ("maxCharacters", `Int 4000) ]) ] );
            ]))
  in
  Client.post ~headers ~body (Uri.of_string "https://api.exa.ai/search")

let api_key = Envlib.read_env "EXA_API_KEY" ()

let request_handler query =
  let open Yojson.Basic in
  let file_cache = "test.json" in
  Sys.file_exists file_cache >>= fun check ->
  if check = `Yes then (
    Reader.file_contents file_cache >>= fun json ->
    from_string json |> Util.member "results" |> to_string |> print_endline;
    Deferred.return ())
  else
    exa_search query api_key >>= fun (_, body) ->
    Body.to_string body >>= fun json ->
    from_string json |> Util.member "results" |> to_string |> print_endline;
    Deferred.return ()

let command =
  Command.async ~summary:"query passed with -q"
    ~readme:(fun () -> "Tha information")
    (Command.Param.map query_flag ~f:(fun query () -> request_handler query))

let () = Command_unix.run ~version:"0.1" ~build_info:"Idk" command

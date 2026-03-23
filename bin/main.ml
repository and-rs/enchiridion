open Async
open Cohttp
open Cohttp_async
open Yojson.Basic.Util

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

let query_function =
  Command.Param.map query_flag ~f:(fun query () ->
      exa_search query api_key >>= fun (_, body) ->
      Body.to_string body >>= fun body_string ->
      Yojson.Basic.from_string body_string
      |> member "results" |> to_list
      |> List.iter (fun r ->
          r |> member "summary" |> to_string |> print_endline);
      Async.return ())

let command =
  Command.async ~summary:"query passed with -q"
    ~readme:(fun () -> "Tha information")
    query_function

let () = Command_unix.run ~version:"0.1" ~build_info:"Idk" command

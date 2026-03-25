open Async
open Cohttp
open Cohttp_async

let api_key = Envlib.read_env "EXA_API_KEY" ()

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

type search_result = { title : string; url : string; highlights : string list }

let parse_json j =
  let open Yojson.Safe.Util in
  let list = Yojson.Safe.from_string j |> member "results" |> to_list in
  List.map
    (fun s ->
      {
        title = s |> member "title" |> to_string;
        url = s |> member "url" |> to_string;
        highlights = s |> member "highlights" |> to_list |> List.map to_string;
      })
    list

let format_terminal list =
  let open Core.Printf in
  List.iter
    (fun r ->
      printf "\n\n#------# \ntitle: %s\nurl: %s\nhighlights:\n%s" r.title r.url
        (String.concat " --- " r.highlights))
    list

let request_handler query =
  let file_cache = "test.json" in
  Sys.file_exists file_cache >>= fun check ->
  if check = `Yes then (
    Reader.file_contents file_cache >>= fun j ->
    parse_json j |> format_terminal;
    Deferred.return ())
  else
    exa_search query api_key >>= fun (_, body) ->
    Body.to_string body >>= fun j ->
    Writer.save file_cache ~contents:j >>| fun () ->
    parse_json j |> format_terminal

let query_flag =
  let open Command.Param in
  flag "-q" (required string) ~doc:"Query; Query for the semantic search"

let command =
  Command.async ~summary:"Search the web using Exa AI"
    ~readme:(fun () ->
      "Performs a semantic search query against the Exa API. Requires \
       EXA_API_KEY environment variable.")
    (Command.Param.map query_flag ~f:(fun query () -> request_handler query))

let () = Command_unix.run ~version:"v0.0.1" ~build_info:"dev" command

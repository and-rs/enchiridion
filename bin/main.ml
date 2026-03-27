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
  List.iteri
    (fun i l ->
      printf "\n\n--- result #%d --- \ntitle: %s\nurl: %s\nhighlights:\n%s"
        (i + 1) l.title l.url
        (String.concat "\n"
           (List.mapi
              (fun i s ->
                Printf.sprintf "--- highlight #%d ---\n\n%s" (i + 1) s)
              l.highlights)))
    list

let request_handler query =
  let file_cache = "test.json" in
  Sys.file_exists file_cache >>= fun check ->
  if check = `Yes then (
    Reader.file_contents file_cache >>= fun j ->
    print_endline j;
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
  Command.async
    ~summary:"Enchiridion: Unix-style AI orchestrator and dataflow pipeline"
    ~readme:(fun () ->
      "Executes LLM prompts via the OpenAI API schema, processing \
       Markdown-based session files and streaming SSE responses to stdout. \
       Supports context augmentation via Exa Search. Requires relevant API \
       keys in the environment.")
    (Command.Param.map query_flag ~f:(fun query () -> request_handler query))

let () = Command_unix.run ~version:"v0.0.1" ~build_info:"dev" command

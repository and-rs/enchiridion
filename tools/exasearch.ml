open Cohttp_eio

let api_key = Dotenv.get_setting "EXA_API_KEY"

let search_request ~sw client (query : string) (key : string) =
  let init_headers = Http.Header.init_with "Content-Type" "application/json" in
  let headers = Http.Header.add init_headers "x-api-key" key in
  let body =
    Cohttp_eio.Body.of_string
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
  Client.post ~headers ~body client ~sw
    (Uri.of_string "https://api.exa.ai/search")

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
      printf "\n\n--- result #%d --- \ntitle: %s\nurl: %s\nhighlights:\n"
        (i + 1) l.title l.url;
      List.iteri
        (fun j s -> printf "--- highlight #%d ---\n\n%s\n" (j + 1) s)
        l.highlights)
    list

(* extracting for readability *)
let read_write_user = 0o644
let overwrite = `Or_truncate read_write_user
let atomic_cache_save path data = Eio.Path.save ~create:overwrite path data

let request_handler ~sw ~fs client (query : string) (test : bool) =
  let file_cache = Eio.Path.(fs / "test.json") in

  let test_content =
    if test then
      match Eio.Path.load file_cache with
      | exception Eio.Io _ -> None
      | content -> Some content
    else None
  in

  match test_content with
  | Some j -> print_endline j
  | None ->
      let resp, body = search_request ~sw client query api_key in
      let code = Http.Status.to_int resp.status in
      let json_buf =
        Eio.Buf_read.(parse_exn take_all) body ~max_size:(5 * 1024 * 1024)
      in
      if code < 200 || code >= 300 then print_endline json_buf
      else (
        atomic_cache_save file_cache json_buf;
        parse_json json_buf |> format_terminal)

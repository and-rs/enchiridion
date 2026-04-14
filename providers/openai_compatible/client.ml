type 'a t = {
  base_url : string;
  api_key : string;
  default_headers : (string * string) list;
  net : [ `Generic ] Eio.Net.ty Eio.Resource.t;
  clock : 'a Eio.Time.clock;
}

let map_status code body =
  let open Types in
  match code with
  | 400 -> BadRequest body
  | 401 -> AuthError body
  | 403 -> PermissionError body
  | 404 -> NotFoundError body
  | 409 -> ConflictError body
  | 422 -> UnprocessableError body
  | 429 -> RateLimitError body
  | c when c >= 500 -> InternalError body
  | c -> UnknownError (c, body)

type event = { id : string option; event : string option; data : string list }

let empty_event = { id = None; event = None; data = [] }

(* TODO: make tests pass and complete parsing *)
let sse_parser (buffer : Eio.Buf_read.t) =
  let lines = Eio.Buf_read.lines buffer in
  let rec unfold_lines s =
    match Seq.uncons s with
    | None -> failwith "unimplemented"
    (* if String.equal line "" then failwith "unimplemented" *)
    (* else if String.starts_with ~prefix:":" line then failwith "unimplemented" *)
    (* else failwith "unimplemented" *)
    | Some (line, rest) ->
        print_endline line;
        unfold_lines rest
  in
  unfold_lines lines

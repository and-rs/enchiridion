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

let read_cached_test_response ~env =
  let fs = Eio.Stdenv.fs env in
  let file_cache = Eio.Path.(fs / "test_completion") in
  match Eio.Path.load file_cache with
  | exception Eio.Io _ -> None
  | file_contents -> Some file_contents

let sse_parser (buffer : Eio.Buf_read.t) =
  let lines = Eio.Buf_read.lines buffer in
  Seq.iter (fun line -> print_endline line) lines

let use_sse_parser ~env =
  match read_cached_test_response ~env with
  | Some s -> sse_parser (Eio.Buf_read.of_string s)
  | None -> print_endline "uhh nothing?"

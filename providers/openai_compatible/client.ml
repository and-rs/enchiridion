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

let sse_parser buffer =
  let lines = Eio.Buf_read.lines buffer in
  let empty_event = { id = None; event = None; data = [] } in
  let is_empty e = e.id = None && e.event = None && e.data = [] in

  let rec unfold s current results =
    match Seq.uncons s with
    | Some ("", rest) ->
        if is_empty current then unfold rest empty_event results
        else
          let completed = { current with data = List.rev current.data } in
          unfold rest empty_event (completed :: results)
    | Some (line, rest) ->
        if String.starts_with ~prefix:"data:" line then
          let len = String.length line in
          let start_idx = if len > 5 && line.[5] = ' ' then 6 else 5 in
          let content = String.sub line start_idx (len - start_idx) in
          let next_event = { current with data = content :: current.data } in
          unfold rest next_event results
        else unfold rest current results
    | None ->
        let final_results =
          if is_empty current then results
          else { current with data = List.rev current.data } :: results
        in
        List.rev final_results
  in
  unfold lines empty_event []

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

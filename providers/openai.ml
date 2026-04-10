module Types = struct
  type role = [ `System | `User | `Assistant | `Tool ]
  type message = { role : role; content : string }

  type delta = {
    content : string option;
    reasoning_content : string option;
    tool_calls : Yojson.Safe.t list option;
  }

  type choice = { index : int; delta : delta; finish_reason : string option }

  type chat_chunk = {
    id : string;
    choices : choice list;
    usage : Yojson.Safe.t option;
  }

  type api_error =
    | AuthError of string
    | PermissionError of string
    | NotFoundError of string
    | RateLimitError of string
    | UnprocessableError of string
    | InternalError of string
    | NetworkError of string
    | UnknownError of int * string

  exception ApiError of api_error

  type 'a client = {
    base_url : string;
    api_key : string;
    default_headers : (string * string) list;
    sw : Eio.Switch.t;
    clock : 'a Eio.Time.clock;
  }

  type sse_event = Delta of chat_chunk | Done
  type block_type = Text | Thinking | ToolCall

  type stream_event =
    | StartBlock of block_type
    | ContentDelta of block_type * string
    | EndBlock of block_type
    | Finish of string option
    | StreamDone
end

open Types

let map_status code body =
  match code with
  | 401 -> AuthError body
  | 403 -> PermissionError body
  | 404 -> NotFoundError body
  | 429 -> RateLimitError body
  | 422 -> UnprocessableError body
  | c when c >= 500 -> InternalError body
  | c -> UnknownError (c, body)

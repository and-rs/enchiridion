type role =
  | Developer
  | System
  | User
  | Assistant
  | Tool
  | Function
  | OtherRole of string

type content = Text of string | Parts of Yojson.Safe.t list

type finish_reason =
  | Stop
  | Length
  | ToolCalls
  | ContentFilter
  | FunctionCall
  | OtherFinishReason of string

type tool_call = {
  id : string option;
  kind : string option;
  name : string option;
  arguments : Yojson.Safe.t option;
  extra : Yojson.Safe.t option;
  raw : Yojson.Safe.t option;
}

type message = {
  role : role;
  content : content option;
  name : string option;
  tool_call_id : string option;
  tool_calls : tool_call list;
  extra : Yojson.Safe.t option;
  raw : Yojson.Safe.t option;
}

type delta = {
  role : role option;
  content_text : string option;
  reasoning_text : string option;
  refusal_text : string option;
  tool_calls : tool_call list;
  extra : Yojson.Safe.t option;
  raw : Yojson.Safe.t option;
}

type choice = {
  index : int;
  delta : delta;
  finish_reason : finish_reason option;
  raw_finish_reason : string option;
  extra : Yojson.Safe.t option;
  raw : Yojson.Safe.t option;
}

type chat_chunk = {
  id : string option;
  object_ : string option;
  created : int option;
  model : string option;
  system_fingerprint : string option;
  choices : choice list;
  usage : Yojson.Safe.t option;
  extra : Yojson.Safe.t option;
  raw : Yojson.Safe.t option;
}

type api_error =
  | BadRequest of string
  | AuthError of string
  | PermissionError of string
  | NotFoundError of string
  | RateLimitError of string
  | ConflictError of string
  | UnprocessableError of string
  | InternalError of string
  | NetworkError of string
  | UnknownError of int * string

exception ApiError of api_error

type sse_event =
  | Delta of chat_chunk
  | Done
  | RawEvent of { event : string option; data : string }

type block_type =
  | Text
  | Thinking
  | ToolCall
  | Refusal
  | UnknownBlock of string

type stream_event =
  | StartBlock of block_type
  | ContentDelta of block_type * string
  | ToolCallDelta of tool_call
  | Metadata of Yojson.Safe.t
  | EndBlock of block_type
  | Finish of finish_reason option * string option
  | StreamDone

let role_of_string = function
  | "developer" -> Developer
  | "system" -> System
  | "user" -> User
  | "assistant" -> Assistant
  | "tool" -> Tool
  | "function" -> Function
  | s -> OtherRole s

let string_of_role = function
  | Developer -> "developer"
  | System -> "system"
  | User -> "user"
  | Assistant -> "assistant"
  | Tool -> "tool"
  | Function -> "function"
  | OtherRole s -> s

let finish_reason_of_string = function
  | "stop" -> Stop
  | "length" -> Length
  | "tool_calls" -> ToolCalls
  | "content_filter" -> ContentFilter
  | "function_call" -> FunctionCall
  | s -> OtherFinishReason s

let string_of_finish_reason = function
  | Stop -> "stop"
  | Length -> "length"
  | ToolCalls -> "tool_calls"
  | ContentFilter -> "content_filter"
  | FunctionCall -> "function_call"
  | OtherFinishReason s -> s

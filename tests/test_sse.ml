open Providers.Openai_compatible.Client

let pp_option pp fmt = function
  | None -> Format.pp_print_string fmt "None"
  | Some x -> Format.fprintf fmt "Some(%a)" pp x

let pp_string_list fmt xs =
  Format.pp_print_string fmt "[";
  let rec loop = function
    | [] -> ()
    | [ x ] -> Format.fprintf fmt "%S" x
    | x :: xs ->
        Format.fprintf fmt "%S; " x;
        loop xs
  in
  loop xs;
  Format.pp_print_string fmt "]"

let pp_event fmt { id; event; data } =
  Format.fprintf fmt "{ id = %a; event = %a; data = %a }"
    (pp_option Format.pp_print_string)
    id
    (pp_option Format.pp_print_string)
    event pp_string_list data

let equal_event a b = a.id = b.id && a.event = b.event && a.data = b.data
let event_testable = Alcotest.testable pp_event equal_event
let events_testable = Alcotest.list event_testable

let test_standard_completion () =
  let input = "data: {\"id\":\"chatcmpl-123\",\"choices\":[...]...}\n\n" in
  let expected =
    [
      {
        id = None;
        event = None;
        data = [ "{\"id\":\"chatcmpl-123\",\"choices\":[...]...}" ];
      };
    ]
  in
  let actual = sse_parser (Eio.Buf_read.of_string input) in
  Alcotest.check events_testable "standard completion" expected actual

let test_done_event () =
  let input = "data: [DONE]\n\n" in
  let expected = [ { id = None; event = None; data = [ "[DONE]" ] } ] in
  let actual = sse_parser (Eio.Buf_read.of_string input) in
  Alcotest.check events_testable "done event" expected actual

let test_ignore_comments () =
  let input = ": ping\ndata: actual payload\n\n: another ping\n\n" in
  let expected = [ { id = None; event = None; data = [ "actual payload" ] } ] in
  let actual = sse_parser (Eio.Buf_read.of_string input) in
  Alcotest.check events_testable "ignore comments" expected actual

let test_multiline_data () =
  let input = "data: first line\ndata: second line\n\n" in
  let expected =
    [ { id = None; event = None; data = [ "first line"; "second line" ] } ]
  in
  let actual = sse_parser (Eio.Buf_read.of_string input) in
  Alcotest.check events_testable "multiline data" expected actual

let suite =
  let open Alcotest in
  [
    test_case "Standard completion" `Quick test_standard_completion;
    test_case "Done event" `Quick test_done_event;
    test_case "Ignore comments" `Quick test_ignore_comments;
    test_case "Multiline data" `Quick test_multiline_data;
  ]

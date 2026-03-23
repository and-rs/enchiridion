let read_env var_name () =
  let lines = In_channel.with_open_text ".env" In_channel.input_lines in
  let list_tuples =
    List.filter_map
      (fun lines ->
        match String.index_opt lines '=' with
        | Some index ->
            Some
              ( String.sub lines 0 index,
                String.sub lines (index + 1) (String.length lines - index - 1)
              )
        | None -> None)
      lines
  in
  match List.find_opt (fun (x, _) -> x = var_name) list_tuples with
  | Some (_, y) -> y
  | None -> failwith ("No value found for provided .env key: " ^ var_name)

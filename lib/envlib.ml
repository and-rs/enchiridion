module ConfigMap = Map.Make (String)

let is_quoted s =
  let len = String.length s in
  len >= 2 && s.[0] = '"' && s.[len - 1] = '"'

let extract_interior s =
  let len = String.length s in
  if len >= 2 then String.sub s 1 (len - 2) else s

let split_1st (str : string) (on : char) =
  match String.index_opt str on with
  | None -> None
  | Some i ->
      let left = String.sub str 0 i in
      let right = String.sub str (i + 1) (String.length str - i - 1) in
      Some (left, right)

let load_config filepath =
  let lines = In_channel.with_open_text filepath In_channel.input_lines in
  List.fold_left
    (fun acc line ->
      match split_1st line '=' with
      | Some (left, right) ->
          ConfigMap.add (String.trim left)
            (String.trim
               (if is_quoted right then extract_interior right else right))
            acc
      | _ -> acc)
    ConfigMap.empty lines

let global_config = lazy (load_config ".env")

let get_setting key =
  let config = Lazy.force global_config in
  match ConfigMap.find_opt key config with
  | Some v -> v
  | None -> failwith ("Missing .env variable: " ^ key)

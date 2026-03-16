open Base

let () = Stdio.print_endline "Hello, World!"
let ratio x y = Float.O.(of_int x / of_int y * 2.0);;

Stdio.print_endline (Float.to_string (ratio 3 4))

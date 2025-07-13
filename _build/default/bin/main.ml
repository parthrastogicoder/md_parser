open Printf

let print_usage () =
  printf "Usage: %s <input.md> <output.html>\n" Sys.argv.(0)

let () =
  match Array.length Sys.argv with
  | 3 ->
      let input_file = Sys.argv.(1) in
      let output_file = Sys.argv.(2) in
      (try
        Markdown_parser.Io.convert_file input_file output_file;
        printf "Converted %s to %s\n" input_file output_file
      with
      | Sys_error msg ->
          eprintf "Error: %s\n" msg;
          exit 1
      | exn ->
          eprintf "Error: %s\n" (Printexc.to_string exn);
          exit 1)
  | _ ->
      print_usage ();
      exit 1

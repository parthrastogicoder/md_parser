let read_file filename =
  let ic = open_in filename in
  let rec read_lines acc =
    try
      let line = input_line ic in
      read_lines (line :: acc)
    with End_of_file ->
      close_in ic;
      List.rev acc
  in
  read_lines []

let write_file filename content =
  let oc = open_out filename in
  output_string oc content;
  close_out oc

let convert_file input_file output_file =
  let lines = read_file input_file in
  let processed_lines = Parser.process_lines lines in
  let enhanced_lines = Parser.enhance_paragraphs processed_lines in
  let body_content = String.concat "\n" enhanced_lines in
  let full_html = Parser.generate_html_document body_content in
  write_file output_file full_html

open Printf

let bold_regex = Str.regexp "\\*\\*\\([^*]+\\)\\*\\*"
let italic_regex = Str.regexp "\\*\\([^*]+\\)\\*"
let h1_regex = Str.regexp "^# \\(.*\\)$"
let h2_regex = Str.regexp "^## \\(.*\\)$"
let h3_regex = Str.regexp "^### \\(.*\\)$"
let list_item_regex = Str.regexp "^- \\(.*\\)$"
let code_span_regex = Str.regexp "`\\([^`]+\\)`"

let convert_bold text =
  Str.global_replace bold_regex "<strong>\\1</strong>" text

let convert_italic text =
  Str.global_replace italic_regex "<em>\\1</em>" text

let convert_code_spans text =
  Str.global_replace code_span_regex "<code>\\1</code>" text

let is_list_item line =
  Str.string_match list_item_regex line 0

let convert_list_item line =
  if is_list_item line then
    sprintf "<li>%s</li>" (Str.matched_group 1 line)
  else
    line

let is_header line =
  Str.string_match h1_regex line 0 ||
  Str.string_match h2_regex line 0 ||
  Str.string_match h3_regex line 0

let convert_headers line =
  if Str.string_match h1_regex line 0 then
    sprintf "<h1>%s</h1>" (Str.matched_group 1 line)
  else if Str.string_match h2_regex line 0 then
    sprintf "<h2>%s</h2>" (Str.matched_group 1 line)
  else if Str.string_match h3_regex line 0 then
    sprintf "<h3>%s</h3>" (Str.matched_group 1 line)
  else
    line

let apply_inline_formatting text =
  text
  |> convert_code_spans
  |> convert_bold
  |> convert_italic

type parse_state = {
  in_list: bool;
  previous_empty: bool;
}

let process_line_with_state state line =
  let trimmed = String.trim line in
  let is_empty = trimmed = "" in
  let is_list = is_list_item trimmed in
  let is_head = is_header trimmed in
  
  let result = 
    if is_empty then
      if state.in_list then
        (false, "</ul>")
      else if state.previous_empty then
        (false, "")
      else
        (false, "<br>")
    else if is_list then
      let list_html = convert_list_item trimmed |> apply_inline_formatting in
      if state.in_list then
        (true, list_html)
      else
        (true, "<ul>\n" ^ list_html)
    else if state.in_list then
      let current_html = 
        if is_head then
          convert_headers trimmed |> apply_inline_formatting
        else
          sprintf "<p>%s</p>" (apply_inline_formatting trimmed)
      in
      (false, "</ul>\n" ^ current_html)
    else if is_head then
      (false, convert_headers trimmed |> apply_inline_formatting)
    else
      (false, sprintf "<p>%s</p>" (apply_inline_formatting trimmed))
  in
  
  let new_state = { 
    in_list = fst result; 
    previous_empty = is_empty 
  } in
  (new_state, snd result)

let process_lines lines =
  let initial_state = { in_list = false; previous_empty = false } in
  let (final_state, processed_lines) = 
    List.fold_left (fun (state, acc) line ->
      let (new_state, html) = process_line_with_state state line in
      (new_state, html :: acc)
    ) (initial_state, []) lines
  in
  let result_lines = List.rev processed_lines in
  if final_state.in_list then
    result_lines @ ["</ul>"]
  else
    result_lines

let enhance_paragraphs html_lines =
  let rec process acc current_para = function
    | [] -> 
        (match current_para with
         | [] -> List.rev acc
         | para -> List.rev (String.concat "\n" para :: acc))
    | line :: rest when line = "" || line = "<br>" ->
        (match current_para with
         | [] -> process acc [] rest
         | para -> process (String.concat "\n" para :: acc) [] rest)
    | line :: rest when String.contains line '<' && 
                       (String.contains line 'h' || 
                        String.contains line 'u' ||
                        String.contains line '/') ->
        let new_acc = match current_para with
          | [] -> line :: acc
          | para -> line :: (String.concat "\n" para) :: acc
        in
        process new_acc [] rest
    | line :: rest ->
        process acc (line :: current_para) rest
  in
  process [] [] html_lines

let generate_html_document ?css body_content =
  let style_content = match css with
    | Some c -> c
    | None -> Styles.default_css
  in
  sprintf "<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Converted Markdown</title>
    <style>%s</style>
</head>
<body>
%s
</body>
</html>" style_content body_content

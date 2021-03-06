open Unix
open Init
open Types
open Arg
open Print
open Parser

let make_lumber note =
  let d : tm = getDate in
  let note_with_metadata = "\n" ^ format_date d ^ "\n" ^ note in
  write_lines !Init.file_ref [ note_with_metadata ];
  let tree = !Init.currentTreeref in
  let new_lum = { date = d; note = note_with_metadata; tags = [] } in
  Init.currentTreeref := Lumber.add_log tree new_lum

let make_note () =
  let rec keep_writing notes =
    let note = input_line Pervasives.stdin in
    if String.length note < 1 then List.rev notes |> String.concat "\n"
    else keep_writing (note :: notes)
  in
  keep_writing [] |> make_lumber

let templates =
  [
    "What did you learn today?";
    "What is your favorite song today?";
    "One thing I would tell myself from a year ago is:";
  ]

let gratitude_journaling =
  [
    "Who are you grateful for today?"; "What in your life are you grateful for?";
  ]

let gen_prompt prompts =
  Random.self_init ();
  let template = List.nth prompts (List.length prompts |> Random.int) in
  print_endline template;
  let resp = input_line Pervasives.stdin in
  let note : string = template ^ "\n" ^ resp in
  make_lumber note

let gen_rand () = gen_prompt templates

let gen_gratitude () = gen_prompt gratitude_journaling

let make_graph () = ()

let get_last_year () =
  let date : tm = getDate in
  let date_last_year = { date with tm_year = date.tm_year - 1 } in
  format_date_dmy date_last_year |> find_occurences

let main (args : string array) =
  if Array.length args < 2 then raise (Failure "No text file specified")
  else
    let speclist =
      [
        ("-i", Arg.String Init.init, "Creates Entry Tree");
        ( "-gd",
          Arg.String print_note,
          "Prints note from date to stdout. Date must be of form MM/DD/YYYY" );
        ( "-gds",
          Arg.String print_range_note,
          "Prints note from date range to stdout. Date range must be of form \
           MM/DD/YYYY-MM/DD/YYYY" );
        ("-ga", Arg.Unit print_all, "Prints all notes");
        ("-f", Arg.String find_occurences, "Finds all notes containing keyword");
        ( "-m",
          Arg.Unit print_metrics,
          "Prints character count metrics from past months" );
        ("-nc", Arg.Unit get_all, "Prints the total number of notes");
        ( "-fc",
          Arg.String print_count,
          "Prints the number of notes containing keyword" );
        ("-r", Arg.Unit gen_rand, "Generate a random note template");
        ("-n", Arg.Unit make_note, "Write a new note");
        ("-g", Arg.Unit make_graph, "Print graph of usage");
        ("-gr", Arg.Unit gen_gratitude, "Gratitude Journaling prompt");
        ("-ly", Arg.Unit get_last_year, "Prints notes from today last year");
      ]
    in
    let usage_msg = "Currently supported options include:" in
    Arg.parse speclist print_endline usage_msg

let () = main Sys.argv

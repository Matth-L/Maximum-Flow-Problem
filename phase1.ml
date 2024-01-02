open Analyse
module Sgraph = Graph.Make (String)

(****************************** write in file ********************************)


let write_phase_1 start goal set =
  (* open / empty a file named phase 1 *)
  let cout = open_out "phase1.txt" in
  (* write in the file *)

let _ =
  let useless1, useless2, l = phase1 () in
  let g = Sgraph.list_to_graph_no_pond l in
  let set = Sgraph.all_shortest_paths "source" "puits" g in
  write_phase_1 s t set

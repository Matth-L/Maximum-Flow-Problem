open Analyse
module Sgraph = Graph.Make (String)

(****************************** write in file ********************************)

let _ =
  let useless1, useless2, l = phase1 () in
  let g = Sgraph.list_to_graph_no_pond l in
  let cin = open_out "phase1.txt" in
  let set = Sgraph.all_shortest_paths "source" "puits" g in
  Sgraph.SetOfPath.iter
    (fun path ->
      let ordered_path = List.rev path in
      List.iter (fun (x, min, max) -> Printf.fprintf cin "%s " x) ordered_path ;
      Printf.fprintf cin "\n" )
    set

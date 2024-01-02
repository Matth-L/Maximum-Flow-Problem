open Analyse
module Sgraph = Graph.Make (String)

(****************************** write in file ********************************)

let _ =
  let useless1, useless2, l = phase2 () in
  (* on charge le graph *)
  let g = Sgraph.list_to_graph_enonce l in
  let cin = open_out "phase2.txt" in
  (* on applique dinic*)
  let final_graph = Sgraph.dinic "source" "puits" g in
  (* on calcule le flot max*)
  let max_flow = Sgraph.get_maximum_flow_from_node "puits" final_graph in
  (* on recupere la liste des arête modifié *)
  let list_of_modified_node_enonce = Sgraph.list_of_modified_node final_graph in
  let num_edge = List.length list_of_modified_node_enonce in
  (* on ecrit dans le fichier *)
  Printf.fprintf cin "%d\n" max_flow ;
  Printf.fprintf cin "%d\n" num_edge ;
  Sgraph.NodeMap.iter
    (fun node succs ->
      Sgraph.NodeMap.iter
        (fun node2 (min, max) ->
          if min != 0 then
            Printf.fprintf cin "%s %s %i\n" node node2 min )
        succs )
    final_graph

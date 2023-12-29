module SGraph = Graph.Make (String)

let pretty_print_all_shortest_paths setPath =
  Printf.printf "all_shortest_paths: \n";
  SGraph.SetOfPath.iter
    (fun path ->
      match path with
      | [] -> ()
      | (first_node, min, max) :: rest_of_path ->
          Printf.printf "Path: [%s,(%i ;%i)]" first_node min max;
          List.iter
            (fun (node, min, max) ->
              Printf.printf " <-- [%s,(%i ;%i)]" node min max)
            rest_of_path;
          Printf.printf "\n")
    setPath

(* fonctionne *)
let listPath =
  let start, goal, path = Analyse.phase1 () in
  let g = SGraph.list_to_graph_no_pond path in
  SGraph.allShortestPaths start goal g

let _ = pretty_print_all_shortest_paths listPath

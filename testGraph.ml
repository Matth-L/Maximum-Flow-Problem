open Graph

(* test effectué avec un graph de lettre *)
module PGraph = Graph.Make (Char)

(********************** is_empty TEST***********************************)

(*test vacuité*)
let _ =
  if PGraph.is_empty PGraph.empty then
    Printf.printf "test_is_empty (graph vide): OK\n"
  else
    Printf.printf "test_is_empty (graph non vide): erreur \n"
;;

(*tets de vacuité avec un graph non vide*)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  if PGraph.is_empty graph then
    Printf.printf "test_is_empty (graph non vide) : erreur\n"
  else
    Printf.printf "test_is_empty (graph non vide) : OK\n"
;;

(********************** mem_node TEST***********************************)

(*test existence d'un noeud*)
let _ =
  let graph = PGraph.add_lonely_node 'x' PGraph.empty in
  let result = PGraph.mem_node 'x' graph in
  if result then
    Printf.printf "test_mem_node (le noeud appartient au graph): OK\n"
  else
    Printf.printf "test_mem_node (le noeud appartient au graph): erreur\n"
;;

(*le noeud n'appartient pas au graph*)
let _ =
  let graph = PGraph.add_lonely_node 'A' PGraph.empty in
  let result = PGraph.mem_node 'V' graph in
  if result then
    Printf.printf "test_mem_node (le noeud n'appartient pas au graph): erreur\n"
  else
    Printf.printf "test_mem_node (le noeud n'appartient pas au graph): OK\n"
;;

(********************** mem_edge TEST***********************************)
(* la fonction retourne une exception si n1 n'est pas dans le graph
   booléen sinon *)

(*test existent d'arête*)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_2_node = PGraph.add_lonely_node 'b' graph in
  let graph_with_edge = PGraph.add_edge 'a' 1 'b' graph_with_2_node in
  if PGraph.mem_edge 'a' 'b' graph_with_edge then
    Printf.printf "test_mem_edge (existence d'arête) : OK\n"
  else
    Printf.printf "test_mem_edge (existence d'arête) : erreur\n"
;;

(*test si l'un des deux noeuds n'existe pas *)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_2_node = PGraph.add_lonely_node 'b' graph in
  if PGraph.mem_edge 'a' 'c' graph_with_2_node then
    Printf.printf "test_mem_edge (l'un des 2 noeuds n'exisent pas): erreur\n"
  else
    Printf.printf "test_mem_edge (l'un des 2 noeuds n'exisent pas): OK\n"
;;

(*test si le premier noeud n'existe pas (doit throw une exception)*)

let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_2_node = PGraph.add_lonely_node 'b' graph in
  try
    let _ = PGraph.mem_edge 'd' 'b' graph_with_2_node in
    Printf.printf "test_mem_edge (le premier noeud n'existe pas) : erreur\n"
  with
  | _ -> Printf.printf "test_mem_edge (le premier noeud n'existe pas): OK\n"
;;

(********************** succs TEST***********************************)

let _ =
  (* on crée un graph avec un noeud *)
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  (* on ajoute un successeur *)
  let graph_with_sucessor_to_n1 = PGraph.add_node 'a' 1 'b' graph in
  (*
     dans la map on a donc 
    {a : {b : 1 }}
  *)
  (* on récupère le succeseur de 1 *)
  let successor_of_n1 = PGraph.succs 'a' graph_with_sucessor_to_n1 in
  (* dans successor_of_n1 on a donc :
     {b : 1}
  *)
  if PGraph.NodeMap.mem 'b' successor_of_n1 then
    Printf.printf "test_succs (le successeur de 1 est 2) : OK\n"
  else
    Printf.printf "test_succs (le successeur de 1 est 2) : erreur\n"
;;

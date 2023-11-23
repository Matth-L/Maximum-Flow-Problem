module PGraph = Graph.Make (Char)
(*
   fonction a tester :
   - is_empty : DONE
   - mem_node : DONE
   - mem_edge : DONE
   - succs : DONE
   - add_lonely_node : DONE
   - add_edge : DONE
   - add_node : DONE
   - remove_edge : TODO
   - remove_node : TODO
*)

(* Beaucoup de test pourrait être condensé en 1 seul mais pour rendre l'impression des test plus explicite je les ai séparé*)

(******************** is_empty TEST ************************)

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
    Printf.printf "test_is_empty (graph vide) : erreur\n"
  else
    Printf.printf "test_is_empty (graph non vide) : OK\n"
;;

(******************** fold_node TEST ************************)

(* pour tester le fold on va faire différentes opérations
   les noeuds pour voir s'il fonctionne *)

(* on va compter le nombre de noeud de différents graph*)

(* test avec un graph vide*)
let _ =
  let graph = PGraph.empty in
  let result = PGraph.fold_node (fun _ acc -> acc + 1) graph 0 in
  if result = 0 then
    Printf.printf "test_fold_node (graph vide) : OK\n"
  else
    Printf.printf "test_fold_node (graph vide) : erreur\n"
;;

(* test avec 3 noeud
   a ---> b
   b ---> c
   c ---> a
*)

let _ =
  let graph_with_a = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_a_b = PGraph.add_node 'a' 1 'b' graph_with_a in
  let graph_with_a_b_c = PGraph.add_node 'b' 9 'c' graph_with_a_b in
  let graph_with_a_b_c_a = PGraph.add_edge 'c' 3 'a' graph_with_a_b_c in
  let result = PGraph.fold_node (fun _ acc -> acc + 1) graph_with_a_b_c_a 0 in
  if result = 3 then
    Printf.printf "test_fold_node (graph avec 3 noeuds) : OK\n"
  else
    Printf.printf "test_fold_node (graph avec 3 noeuds) : erreur\n"
;;

(******************** fold_edge TEST ************************)

(*TODO*)

(******************** mem_node TEST ************************)

(*test existence d'un noeud*)
let _ =
  let graph = PGraph.add_lonely_node 'x' PGraph.empty in
  let result = PGraph.mem_node 'x' graph in
  if result then
    Printf.printf "test_mem_node (le noeud appartient au graph): OK\n"
  else
    Printf.printf "test_mem_node (le noeud n'appartient pas au graph): erreur\n"
;;

(*le noeud n'appartient pas au graph*)
let _ =
  let graph = PGraph.add_lonely_node 'A' PGraph.empty in
  let result = PGraph.mem_node 'V' graph in
  if result then
    Printf.printf "test_mem_node (le noeud appartient au graph): erreur\n"
  else
    Printf.printf "test_mem_node (le noeud n'appartient pas au graph): OK\n"
;;

(******************** mem_edge TEST ************************)
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

(******************** succs TEST ************************)

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

(******************** add_lonely_node TEST ************************)

(* test l'existence d'un noeud lors de son ajout *)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  if PGraph.mem_node 'a' graph then
    Printf.printf "test_add_lonely_node (ajout d'un noeud) : OK\n"
  else
    Printf.printf "test_add_lonely_node (ajout d'un noeud) : erreur\n"
;;

(* test que ce noeud n'a bien pas de successeur*)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let successor_of_n1 = PGraph.succs 'a' graph in
  if PGraph.NodeMap.is_empty successor_of_n1 then
    Printf.printf "test_add_lonely_node (le noeud n'a pas de successeur) : OK\n"
  else
    Printf.printf
      "test_add_lonely_node (le noeud n'a pas de successeur) : erreur\n"
;;

(******************** add_edge TEST ************************)

(* test qui vérifie si A ----> B  et que A <------ B n'existe pas *)
let _ =
  let graph =
    PGraph.add_lonely_node 'b' (PGraph.add_lonely_node 'a' PGraph.empty)
  in
  let connected_graph = PGraph.add_edge 'a' 3 'b' graph in
  let a_vers_b = PGraph.mem_edge 'a' 'b' connected_graph in
  let b_vers_a = PGraph.mem_edge 'b' 'a' connected_graph in
  if a_vers_b && not b_vers_a then
    Printf.printf "test_edge (A ---> B existe) : OK\n"
  else
    Printf.printf "test_edge (A ---> B existe) : erreur\n"
;;

(******************** add_node TEST ************************)

(* test si le noeud demandé est rajouter ET connecter au noeud demandé

   avant : graph avec juste un noeud ex: 'a'
   après : a ---(1)---> b
*)
let _ =
  let lonely_graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_a_b = PGraph.add_node 'a' 1 'b' lonely_graph in
  let node_created = PGraph.mem_node 'b' graph_with_a_b in
  if node_created then
    Printf.printf "test_add_node (le nouveau noeud B existe) : OK\n"
  else
    Printf.printf "test_add_node (le nouveau noeud B existe) : erreur\n"
;;

(* test si l'arête a bien été crée*)
let _ =
  let lonely_graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_a_b = PGraph.add_node 'a' 1 'b' lonely_graph in
  let edge_created = PGraph.mem_edge 'a' 'b' graph_with_a_b in
  if edge_created then
    Printf.printf "test_add_node (A ---> B existe) : OK\n"
  else
    Printf.printf "test_add_node (A ---> B existe) : erreur\n"
;;

(* test qui vérifie que add_node 'a' 'a' ne crée pas une boucle*)
let _ =
  let graph_with_a_a =
    PGraph.add_node 'a' 1 'a' (PGraph.add_lonely_node 'a' PGraph.empty)
  in
  if PGraph.mem_edge 'a' 'a' graph_with_a_a then
    Printf.printf "test_add_node (A ---> A existe) : erreur\n"
  else
    Printf.printf "test_add_node (A ---> A n'existe pas) : OK\n"
;;

(******************** remove_edge TEST ************************)

(* test qui vérifie si l'arête a bien été supprimer ,
   càd que n2 n'est plus dans les successeurs de n1 *)

let _ =
  let graph_with_a_b =
    PGraph.add_node 'a' 1 'b' (PGraph.add_lonely_node 'a' PGraph.empty)
  in
  let graph_two_lonely_node = PGraph.remove_edge 'a' 'b' graph_with_a_b in
  if PGraph.mem_edge 'a' 'b' graph_two_lonely_node then
    Printf.printf "test remove_edge (A et B sont isolé) : erreur\n"
  else
    Printf.printf "test remove_edge (A et B sont isolé) : OK\n"
;;

(*test si malgré une boucle A n'a pas été supprimé *)
let _ =
  let graph_with_a_a =
    PGraph.add_node 'a' 1 'a' (PGraph.add_lonely_node 'a' PGraph.empty)
  in
  let g = PGraph.remove_edge 'a' 'a' graph_with_a_a in
  if PGraph.mem_node 'a' g then
    Printf.printf
      "test remove_edge (A existe toujours en enlevant sa boucle) : OK\n"
  else
    Printf.printf
      "test remove_edge (A existe toujours en enlevant sa boucle) : erreur\n"
;;

(* test si malgré une boucle l'arête a bien été enlevé*)

let _ =
  let graph_with_a_a =
    PGraph.add_node 'a' 1 'a' (PGraph.add_lonely_node 'a' PGraph.empty)
  in
  let g = PGraph.remove_edge 'a' 'a' graph_with_a_a in
  if PGraph.mem_edge 'a' 'a' g then
    Printf.printf
      "test remove_edge (A ---> A existe toujours en enlevant sa boucle) : \n\
      \       erreur\n"
  else
    Printf.printf "test remove_edge (A ---> A n'existe plus) : OK\n"
;;

(******************** remove_node TEST ************************)

(* test qui vérifie si le noeud est bien enlevé du graph *)

(*
   a ------> b
   b ------> b
   c ------> b
   a ------> c
*)

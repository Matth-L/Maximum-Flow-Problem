module PGraph = Graph.Make (Char)

(* Beaucoup de test pourrait être condensé en 1 seul mais pour rendre l'impression des test plus explicite je les ai séparé*)

(******************** is_empty TEST ************************)

(*test vacuité*)
let _ =
  if PGraph.is_empty PGraph.empty then
    Printf.printf "test_is_empty (graph vide -> true): OK\n"
  else
    Printf.printf "test_is_empty (graph non vide): erreur \n"

(*test de vacuité avec un graph non vide*)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  if PGraph.is_empty graph then
    Printf.printf "test_is_empty (graph vide) : erreur\n"
  else
    Printf.printf "test_is_empty (graph non vide -> false) : OK\n"

(******************** fold_node TEST ************************)

(* pour tester le fold on va faire différentes opérations
   les noeuds pour voir s'il fonctionne *)

(* on va compter le nombre de noeud de différents graph*)

(* test avec un graph vide*)
let _ =
  let graph = PGraph.empty in
  let result = PGraph.fold_node (fun _ acc -> acc + 1) graph 0 in
  if result = 0 then
    Printf.printf "test_fold_node (graph vide -> 0 noeud) : OK\n"
  else
    Printf.printf "test_fold_node : erreur\n"

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
    Printf.printf "test_fold_node : erreur\n"

(******************** fold_succs TEST ************************)

(* compte le nombre d'arc *)
let _ =
  let graph_with_a = PGraph.add_lonely_node 'a' PGraph.empty in
  (* a ---> b *)
  let graph_with_a_b = PGraph.add_node 'a' 1 'b' graph_with_a in
  (* b ---> c *)
  let graph_with_a_b_c = PGraph.add_node 'b' 1 'c' graph_with_a_b in
  (* c ---> a *)
  let graph_with_a_b_c_a = PGraph.add_edge 'c' 1 'a' graph_with_a_b_c in
  (*a ---> c *)
  let final = PGraph.add_edge 'a' 1 'c' graph_with_a_b_c_a in
  let result =
    PGraph.fold_succs (fun noeud ponderation acc -> acc + 1) final 0
  in
  if result = 4 then
    Printf.printf "test_fold_succs (graph avec 4 arc) : OK\n"
  else
    Printf.printf "test_fold_succs (graph pas avec 4 arc) : erreur\n"

(******************** mem_node TEST ************************)

(*test existence d'un noeud*)
let _ =
  let graph = PGraph.add_lonely_node 'x' PGraph.empty in
  let result = PGraph.mem_node 'x' graph in
  if result then
    Printf.printf "test_mem_node (le noeud 'x' appartient au graph): OK\n"
  else
    Printf.printf
      "test_mem_node (le noeud 'x' n'appartient pas au graph): erreur\n"

(*le noeud n'appartient pas au graph*)
let _ =
  let graph = PGraph.add_lonely_node 'A' PGraph.empty in
  let result = PGraph.mem_node 'V' graph in
  if result then
    Printf.printf "test_mem_node (le noeud appartient au graph): erreur\n"
  else
    Printf.printf "test_mem_node (le noeud 'V' n'appartient pas au graph): OK\n"

(******************** mem_edge TEST ************************)
(* la fonction retourne une exception si n1 n'est pas dans le graph
   booléen sinon *)

(*test existent d'arête*)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_2_node = PGraph.add_lonely_node 'b' graph in
  let graph_with_edge = PGraph.add_edge 'a' 1 'b' graph_with_2_node in
  if PGraph.mem_edge 'a' 'b' graph_with_edge then
    Printf.printf "test_mem_edge ( a ----> b existe) : OK\n"
  else
    Printf.printf "test_mem_edge ( a ----> b n'existe pas ) : erreur\n"

(*test si l'un des deux noeuds n'existe pas *)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_2_node = PGraph.add_lonely_node 'b' graph in
  if PGraph.mem_edge 'a' 'c' graph_with_2_node then
    Printf.printf "test_mem_edge (l'un des 2 noeuds n'exisent pas): erreur\n"
  else
    Printf.printf "test_mem_edge (l'un des 2 noeuds n'exisent pas): OK\n"

(*test si le premier noeud n'existe pas (doit throw une exception)*)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_2_node = PGraph.add_lonely_node 'b' graph in
  try
    let _ = PGraph.mem_edge 'd' 'b' graph_with_2_node in
    Printf.printf "test_mem_edge (le premier noeud n'existe pas) : erreur\n"
  with _ ->
    Printf.printf "test_mem_edge (le premier noeud n'existe pas): OK\n"

(******************** mem_exist_as_successor TEST ************************)

(* test si le noeud a est un successeur d'un noeud *)
(*
   b --> a --> c
*)
let _ =
  (*b-->a*)
  let graph =
    PGraph.add_node 'b' 4 'a' (PGraph.add_lonely_node 'b' PGraph.empty)
  in
  (*a-->c*)
  let full_graph = PGraph.add_node 'a' 2 'c' graph in
  (* a est le successeur de b donc vrai *)
  let result = PGraph.mem_exist_as_successor 'a' full_graph in
  if result then
    Printf.printf
      "test_mem_exist_as_successor (A est un successeur d'un noeud) : OK\n"
  else
    Printf.printf
      "test_mem_exist_as_successor (A n'est pas un successeur d'un noeud) : \
       erreur\n"

(* test si le noeud b n'est pas un successeur*)
(*
   b --> a --> c
*)
let _ =
  (*b-->a*)
  let graph =
    PGraph.add_node 'b' 1 'a' (PGraph.add_lonely_node 'b' PGraph.empty)
  in
  (*a-->c*)
  let full_graph = PGraph.add_node 'a' 1 'c' graph in
  (* b n'est le successeur de personne donc faux*)
  let result = PGraph.mem_exist_as_successor 'b' full_graph in
  if result then
    Printf.printf
      "test_mem_exist_as_successor (B est le successeur d'un noeud) : erreur\n"
  else
    Printf.printf
      "test_mem_exist_as_successor (B n'est pas le successeur d'un noeud) : OK\n"

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

(******************** add_lonely_node TEST ************************)

(* test l'existence d'un noeud lors de son ajout *)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  if PGraph.mem_node 'a' graph then
    Printf.printf "test_add_lonely_node (ajout d'un noeud seul) : OK\n"
  else
    Printf.printf "test_add_lonely_node (ajout d'un noeud) : erreur\n"

(* test que ce noeud n'a bien pas de successeur*)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let successor_of_n1 = PGraph.succs 'a' graph in
  if PGraph.NodeMap.is_empty successor_of_n1 then
    Printf.printf
      "test_add_lonely_node (le noeud est ajouté sans successeurs) : OK\n"
  else
    Printf.printf
      "test_add_lonely_node (le noeud n'a pas de successeur) : erreur\n"

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
    Printf.printf "test_edge (A ---> B existe et A <---- B n'existe pas) : OK\n"
  else
    Printf.printf "test_edge (A ---> B n'existe pas) : erreur\n"

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
    Printf.printf "test_add_node (le nouveau noeud B n'existe pas ) : erreur\n"

(* test si l'arête a bien été crée*)
let _ =
  let lonely_graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_a_b = PGraph.add_node 'a' 1 'b' lonely_graph in
  let edge_created = PGraph.mem_edge 'a' 'b' graph_with_a_b in
  if edge_created then
    Printf.printf "test_add_node (A ---> B existe) : OK\n"
  else
    Printf.printf "test_add_node (A ---> B n'existe pas) : erreur\n"

(* test qui vérifie que add_node 'a' 'a' ne crée pas une boucle*)
let _ =
  let graph_with_a_a =
    PGraph.add_node 'a' 1 'a' (PGraph.add_lonely_node 'a' PGraph.empty)
  in
  if PGraph.mem_edge 'a' 'a' graph_with_a_a then
    Printf.printf "test_add_node (une boucle est crée de A ---> A ) : erreur\n"
  else
    Printf.printf "test_add_node (A ---> A n'existe pas) : OK\n"

(******************** remove_edge TEST ************************)

(* test qui vérifie si l'arête a bien été supprimer ,
   càd que n2 n'est plus dans les successeurs de n1 *)

let _ =
  let graph_with_a_b =
    PGraph.add_node 'a' 1 'b' (PGraph.add_lonely_node 'a' PGraph.empty)
  in
  let graph_two_lonely_node = PGraph.remove_edge 'a' 'b' graph_with_a_b in
  if PGraph.mem_edge 'a' 'b' graph_two_lonely_node then
    Printf.printf "test_remove_edge (A et B ne sont pas isolé) : erreur\n"
  else
    Printf.printf "test_remove_edge (A et B sont isolé) : OK\n"

(*test si malgré une boucle A n'a pas été supprimé *)
let _ =
  let graph_with_a_a =
    PGraph.add_node 'a' 1 'a' (PGraph.add_lonely_node 'a' PGraph.empty)
  in
  let g = PGraph.remove_edge 'a' 'a' graph_with_a_a in
  if PGraph.mem_node 'a' g then
    Printf.printf
      "test_remove_edge (A existe toujours en enlevant sa boucle) : OK\n"
  else
    Printf.printf
      "test_remove_edge (A n'existe plus en enlevant sa boucle) : erreur\n"

(******************** remove_node TEST ************************)

(* test qui vérifie si le noeud est bien enlevé du graph *)

(*
   a ------> b (step 1)
   a ------> c (step 2)
   b ------> b (step 3)
   c ------> b (step 4)
*)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let step_1 = PGraph.add_node 'a' 1 'b' graph in
  let step_2 = PGraph.add_node 'a' 1 'c' step_1 in
  let step_3 = PGraph.add_edge 'b' 1 'b' step_2 in
  let step_4 = PGraph.add_edge 'c' 1 'b' step_3 in
  let step_5 = PGraph.remove_node 'a' step_4 in
  if PGraph.mem_node 'a' step_5 then
    Printf.printf "test_remove_node (A existe toujours) : erreur\n"
  else
    Printf.printf "test_remove_node (A n'existe plus) : OK\n"

(* test si A n'est plus dans les autres *)
(*
   b ------> a (step 1)
   c ------> a (step 2)
   a ------> a (step 3)
*)
let _ =
  let graph = PGraph.add_lonely_node 'b' PGraph.empty in
  let step_1 = PGraph.add_node 'b' 1 'a' graph in
  let step_2 = PGraph.add_lonely_node 'c' step_1 in
  let step_2_bis = PGraph.add_edge 'c' 1 'a' step_2 in
  let step_3 = PGraph.add_edge 'a' 1 'a' step_2_bis in
  let removedA = PGraph.remove_node 'a' step_3 in
  let result = PGraph.mem_exist_as_successor 'a' removedA in
  if result then
    Printf.printf
      "test_remove_node (A a été trouvé comme successeur) : erreur\n"
  else
    Printf.printf
      "test_remove_node (A n'a pas été trouvé comme successeur) : OK\n"

(******************** number_of_incoming_edge TEST ************************)

(**
                  ----
                  |  |
                  v  |
   a ---> b ----> c --
   |              ^
   |--------------|

   c à 2 noeud qui pointe vers lui

   { a  : {b : 1} {c : 1}
     b  : {c : 1}
     c  : {c : 1}
   }
*)
let _ =
  let step_1 = PGraph.add_lonely_node 'a' PGraph.empty in
  (* a ---> b *)
  let step_2 = PGraph.add_node 'a' 1 'b' step_1 in
  (* b ---> c *)
  let step_3 = PGraph.add_node 'b' 1 'c' step_2 in
  (*a ---> c *)
  let step_4 = PGraph.add_edge 'a' 1 'c' step_3 in
  let final = PGraph.add_edge 'c' 1 'c' step_4 in
  let incoming_edge = PGraph.number_of_incoming_edge 'c' final in
  if incoming_edge = 3 then
    Printf.printf
      "test number_of_incoming_edge (C à le bon nombre d'arc entrant) : OK\n"
  else
    Printf.printf
      "test number_of_incoming_edge (C à le bon nombre d'arc entrant) : erreur\n"

(******************** number_of_outgoing_edge TEST ************************)

(**
                  ----
                  |  |
                  v  |
   a ---> b ----> c --
   |              ^
   |--------------|


   { a  : {b : 1} {c : 1}
     b  : {c : 1}
     c
   }

   a à 2 arête qui le quitte
*)
let _ =
  let step_1 = PGraph.add_lonely_node 'a' PGraph.empty in
  (* a ---> b *)
  let step_2 = PGraph.add_node 'a' 1 'b' step_1 in
  (* b ---> c *)
  let step_3 = PGraph.add_node 'b' 1 'c' step_2 in
  (*a ---> c *)
  let step_4 = PGraph.add_edge 'a' 1 'c' step_3 in
  let final = PGraph.add_edge 'c' 1 'c' step_4 in
  let outgoing_edge = PGraph.number_of_outgoing_edge 'a' final in
  if outgoing_edge = 2 then
    Printf.printf
      "test number_of_outgoing_edge (A à le bon nombre d'arc sortant) : OK\n"
  else
    Printf.printf
      "test number_of_outgoing_edge (A n'a pas le bon nombre d'arc sortant) : \
       erreur\n"

(******************** add_paths TEST ************************)
(*
  semble fonctionner 
             |-----> f
             |
     a ----> b ----> c
     |               ^
     |-----> d       |
     |               |
     |-----> e ----> g
     test
*)

let _ =
  (* set de Test *)
  let step_1 = PGraph.add_lonely_node 'a' PGraph.empty in
  let step_2 = PGraph.add_node 'a' 1 'b' step_1 in
  let step_3 = PGraph.add_node 'a' 1 'd' step_2 in
  let step_4 = PGraph.add_node 'a' 1 'e' step_3 in
  let step_5 = PGraph.add_node 'b' 1 'c' step_4 in
  let step_6 = PGraph.add_node 'e' 1 'g' step_5 in
  let step_7 = PGraph.add_node 'b' 1 'f' step_6 in
  let finalGraph = PGraph.add_edge 'g' 1 'c' step_7 in

  (*test bfs*)
  let normallySameSet = PGraph.bfs 'a' 'c' finalGraph in

  (*printing the whole set *)
  Printf.printf "printing the whole set : \n";
  PGraph.SetOfPath.iter
    (fun path ->
      List.iter (fun (node, ponderation) -> Printf.printf "%c" node) path;
      Printf.printf "\n")
    normallySameSet

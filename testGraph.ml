module PGraph = Graph.Make (Char)

let prettyPrint test nameOfTest commentaire =
  if test then
    Printf.printf "%s %s : OK \n" nameOfTest commentaire
  else
    Printf.printf "%s %s : NOT OK \n" nameOfTest commentaire

(* Beaucoup de test pourrait être condensé en 1 seul mais pour rendre l'impression des test plus explicite je les ai séparé*)

(******************** is_empty TEST ************************)

(*test vacuité*)
let _ =
  prettyPrint
    (PGraph.is_empty PGraph.empty)
    "test_is_empty" "test graph vide de base"

(*test de vacuité avec un graph non vide*)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  prettyPrint (not (PGraph.is_empty graph)) "test_is_empty" "graph non vide"

(******************** fold_node TEST ************************)

(* pour tester le fold on va faire différentes opérations
   les noeuds pour voir s'il fonctionne *)

(* on va compter le nombre de noeud de différents graph*)

(* test avec un graph vide*)
let _ =
  let graph = PGraph.empty in
  let result = PGraph.fold_node (fun _ acc -> acc + 1) graph 0 in
  prettyPrint (result = 0) "test_fold_node" "graph vide -> 0 noeud"

(* test avec 3 noeud
   a ---> b ----> c
   ^              |
   |--------------|
*)

let _ =
  let graph =
    PGraph.list_to_graph
      [ ('a', 1, 'b'); ('b', 9, 'c'); ('c', 3, 'a') ]
      PGraph.empty
  in
  let result = PGraph.fold_node (fun _ acc -> acc + 1) graph 0 in
  prettyPrint (result = 3) "test_fold_node" "graph avec 3 noeuds"

(******************** fold_succs TEST ************************)

(* test avec 3 noeud
   a ---> b ----> c
   ^              ^
   |--------------|
*)

(* compte le nombre d'arc *)
let _ =
  let graph =
    PGraph.list_to_graph
      [ ('a', 1, 'b'); ('b', 1, 'c'); ('c', 1, 'a'); ('a', 1, 'c') ]
      PGraph.empty
  in
  let result =
    PGraph.fold_succs (fun noeud ponderation acc -> acc + 1) graph 0
  in
  prettyPrint (result = 4) "test_fold_succs" "graph avec 4 arc"

(******************** mem_node TEST ************************)

(*test existence d'un noeud*)
let _ =
  let graph = PGraph.add_lonely_node 'x' PGraph.empty in
  let result = PGraph.mem_node 'x' graph in
  prettyPrint result "test_mem_node" "le noeud x appartient au graph"

(*un noeud qui n'appartient pas au graph, n'appartient pas au graph ... *)
let _ =
  let graph = PGraph.add_lonely_node 'A' PGraph.empty in
  let result = PGraph.mem_node 'V' graph in
  prettyPrint (not result) "test_mem_node" "V not in GraphA "

(******************** mem_edge TEST ************************)
(* la fonction retourne une exception si n1 n'est pas dans le graph
   booléen sinon *)

(*test existent d'arête*)
let _ =
  let graph = PGraph.list_to_graph [ ('a', 1, 'b') ] PGraph.empty in
  prettyPrint (PGraph.mem_edge 'a' 'b' graph) "test_mem_edge" "A ---> B existe"

(*test si l'un des deux noeuds n'existe pas *)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_2_node = PGraph.add_lonely_node 'b' graph in
  prettyPrint
    (not (PGraph.mem_edge 'a' 'c' graph_with_2_node))
    "test_mem_edge" "A ---> C n'existe pas"

(*test si le premier noeud n'existe pas (doit throw une exception)*)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let graph_with_2_node = PGraph.add_lonely_node 'b' graph in
  prettyPrint
    (not (PGraph.mem_edge 'c' 'b' graph_with_2_node))
    "test_mem_edge" "C ---> B n'existe pas"

(******************** mem_exist_as_successor TEST ************************)

(* test si le noeud a est un successeur d'un noeud *)
(*
   b --> a --> c
*)
let _ =
  let graph =
    PGraph.list_to_graph [ ('b', 4, 'a'); ('a', 2, 'c') ] PGraph.empty
  in
  (* a est le successeur de b donc vrai *)
  let result = PGraph.mem_exist_as_successor 'a' graph in
  prettyPrint result "test_mem_exist_as_successor"
    "A est le successeur d'un noeud"

(* test si le noeud b n'est pas un successeur*)
let _ =
  let graph =
    PGraph.list_to_graph [ ('a', 1, 'b'); ('a', 1, 'c') ] PGraph.empty
  in
  (* b n'est le successeur de personne donc faux*)
  let result = PGraph.mem_exist_as_successor 'b' graph in
  prettyPrint result "test_mem_exist_as_successor"
    "B est le successeur d'aucun noeud"

(******************** succs TEST ************************)

let _ =
  (* on crée un graph avec un noeud *)
  let graph = PGraph.list_to_graph [ ('a', 1, 'b') ] PGraph.empty in
  (*
     dans la map on a donc 
    {a : {b : 1 }}
  *)
  (* on récupère le succeseur de a *)
  let successor_of_n1 = PGraph.succs 'a' graph in
  (* dans successor_of_n1 on a donc :
     {b : 1}
  *)
  prettyPrint
    (PGraph.NodeMap.mem 'b' successor_of_n1)
    "test_succs" "le successeur de a est b"

(******************** add_lonely_node TEST ************************)

(* test l'existence d'un noeud lors de son ajout *)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  prettyPrint
    (PGraph.mem_node 'a' graph)
    "test_add_lonely_node" "le noeud a est ajouté"

(* test que ce noeud n'a bien pas de successeur*)
let _ =
  let graph = PGraph.add_lonely_node 'a' PGraph.empty in
  let successor_of_n1 = PGraph.succs 'a' graph in
  prettyPrint
    (PGraph.NodeMap.is_empty successor_of_n1)
    "test_add_lonely_node" "le noeud n'a pas de successeur"

(******************** add_edge TEST ************************)

(* test qui vérifie si A ----> B  et que A <------ B n'existe pas *)
let _ =
  let graph = PGraph.list_to_graph [ ('a', 3, 'b') ] PGraph.empty in
  let a_vers_b = PGraph.mem_edge 'a' 'b' graph in
  let b_vers_a = PGraph.mem_edge 'b' 'a' graph in
  prettyPrint (a_vers_b && not b_vers_a) "test_edge"
    "A ---> B existe et A <---- B n'existe pas"

(******************** add_node TEST ************************)

(* test si le noeud demandé est rajouter ET connecter au noeud demandé

   avant : graph avec juste un noeud ex: 'a'
   après : a ---(1)---> b
*)
let _ =
  let graph = PGraph.list_to_graph [ ('a', 1, 'b') ] PGraph.empty in
  let node_created = PGraph.mem_node 'b' graph in
  prettyPrint node_created "test_add_node" "le nouveau noeud B existe"

(* test si l'arête a bien été crée*)
let _ =
  let graph = PGraph.list_to_graph [ ('a', 1, 'b') ] PGraph.empty in
  let edge_created = PGraph.mem_edge 'a' 'b' graph in
  prettyPrint edge_created "test_add_node" "l'arête A ---> B existe"

(* test qui vérifie que add_node 'a' 'a' ne crée pas une boucle*)
let _ =
  let graph = PGraph.list_to_graph [ ('a', 1, 'a') ] PGraph.empty in
  let graphWithCycle = PGraph.add_edge 'a' 1 'a' graph in
  prettyPrint
    (PGraph.mem_edge 'a' 'a' graphWithCycle)
    "test_add_node" "A---> A n'existe pas "

(******************** remove_edge TEST ************************)

(* test qui vérifie si l'arête a bien été supprimer ,
   càd que n2 n'est plus dans les successeurs de n1 *)

let _ =
  let graph = PGraph.list_to_graph [ ('a', 1, 'b') ] PGraph.empty in
  let graph_two_lonely_node = PGraph.remove_edge 'a' 'b' graph in
  prettyPrint
    (not (PGraph.mem_edge 'a' 'b' graph_two_lonely_node))
    "test_remove_edge" "A ---> B n'existe plus"

(*test si malgré une boucle , A n'a pas été supprimé *)
let _ =
  let graph = PGraph.list_to_graph [ ('a', 1, 'a') ] PGraph.empty in
  let g = PGraph.remove_edge 'a' 'a' graph in
  prettyPrint (PGraph.mem_node 'a' g) "test_remove_edge"
    "A existe toujours en enlevant sa boucle"

(******************** remove_node TEST ************************)

(* test qui vérifie si le noeud est bien enlevé du graph *)

(*

                |-|
                v |
    a---------->b--
    |           ^
    |           |
    |---------->c
*)
let _ =
  let graph =
    PGraph.list_to_graph
      [ ('a', 1, 'b'); ('a', 1, 'c'); ('c', 1, 'b') ]
      PGraph.empty
  in
  let addedCycle = PGraph.add_edge 'b' 1 'b' graph in
  let removedA = PGraph.remove_node 'a' addedCycle in
  prettyPrint
    (not (PGraph.mem_node 'a' removedA))
    "test_remove_node" "A n'existe plus"

(* test si A n'est plus dans les autres *)
(*
         |----|
         |    |
         v    |
b -----> a ----
         ^
c--------|
*)
let _ =
  let graph =
    PGraph.list_to_graph [ ('b', 1, 'a'); ('c', 1, 'a') ] PGraph.empty
  in
  let graphWithCycle = PGraph.add_edge 'a' 1 'a' graph in
  let removedA = PGraph.remove_node 'a' graphWithCycle in
  let result = PGraph.mem_exist_as_successor 'a' removedA in
  prettyPrint (not result) "test_remove_node"
    "A n'est plus dans les successeurs des autres noeuds"

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
  let graph =
    PGraph.list_to_graph
      [ ('a', 1, 'b'); ('b', 1, 'c'); ('a', 1, 'c') ]
      PGraph.empty
  in
  let final = PGraph.add_edge 'c' 1 'c' graph in
  let incoming_edge = PGraph.number_of_incoming_edge 'c' final in
  prettyPrint (incoming_edge = 3) "test number_of_incoming_edge"
    "C à le bon nombre d'arc entrant"

(******************** number_of_outgoing_edge **************************)

(**
                  |--|
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
  let graph =
    PGraph.list_to_graph
      [ ('a', 1, 'b'); ('b', 1, 'c'); ('a', 1, 'c') ]
      PGraph.empty
  in
  let final = PGraph.add_edge 'c' 1 'c' graph in
  let outgoing_edge = PGraph.number_of_outgoing_edge 'a' final in
  prettyPrint (outgoing_edge = 2) "test number_of_outgoing_edge "
    "(A à le bon nombre d'arc sortant)"

(******************** add_paths TEST ************************)
(*
  semble fonctionner 
             |-----> f
             |       |
             |       v
     a ----> b ----> c <---
     |               ^    |
     |-----> d       |    |
     |               |    |
     |-----> e ----> g    |
             |            |
             |------------|

     + boucle sur b
     graph test
*)

let _ =
  (* set de Test *)
  let graph =
    PGraph.list_to_graph
      [
        ('a', 1, 'b');
        ('a', 6, 'd');
        ('a', 8, 'e');
        ('b', 7, 'c');
        ('e', 2, 'g');
        ('b', 3, 'f');
        ('g', 4, 'c');
        ('f', 5, 'c');
        ('e', 6, 'c');
      ]
      PGraph.empty
  in
  (* test avec des cycles*)
  let addedCycles = PGraph.add_edge 'b' 1 'b' graph in
  (*test bfs*)
  let normallySameSet = PGraph.allShortestPaths 'a' 'c' addedCycles in
  (*printing the whole set *)
  Printf.printf "printing set : \n";
  PGraph.SetOfPath.iter
    (fun path ->
      List.iter (fun (node, ponderation) -> Printf.printf "%c" node) path;
      Printf.printf "\n")
    normallySameSet

(******************** TEST naive phase 2************************)

(*
  semble fonctionner 
             |-----> f
             3       5
             |       |
             |       v
     a -1--> b --7-> c <---
     |               ^    |
     |--6--> d       4    |
     |               |    6
     |---8-> e -2--> g    |
             |            |
             |------------|

     + boucle sur b
     graph test
*)

let _ =
  (* set de Test *)
  let graph =
    PGraph.list_to_graph
      [
        ('a', 1, 'b');
        ('a', 6, 'd');
        ('a', 8, 'e');
        ('b', 7, 'c');
        ('e', 2, 'g');
        ('b', 3, 'f');
        ('g', 4, 'c');
        ('f', 5, 'c');
        ('e', 6, 'c');
      ]
      PGraph.empty
  in
  let graphTarget = PGraph.all_path 'a' 'c' graph in
  let finalSet = PGraph.ponderation_of_set graphTarget in
  let longestSet = PGraph.longestPath finalSet in

  (*printing the whole set *)
  Printf.printf "printing the whole set : \n";
  PGraph.SetOfPhase2.iter
    (fun (n, path) ->
      let _ = Printf.printf "pond : %i \n" n in
      List.iter (fun (node, ponderation) -> Printf.printf "%c" node) path;
      Printf.printf "\n")
    longestSet

(******************** TEST dinic ************************)

(*test nombre de niveau*)

let _ =
  let graph =
    PGraph.list_to_graph
      [
        ('a', 1, 'b');
        ('a', 6, 'd');
        ('a', 8, 'e');
        ('b', 7, 'c');
        ('e', 2, 'g');
        ('b', 3, 'f');
        ('g', 4, 'c');
        ('f', 5, 'c');
        ('e', 6, 'c');
      ]
      PGraph.empty
  in
  let all_path = PGraph.allShortestPaths 'a' 'c' graph in
  (*compte le nombre de niveau*)
  let listLength =
    (* on enlève -2 car le puit et la source sont dedans *)
    PGraph.SetOfPath.fold (fun l acc -> (List.length l - 2) :: acc) all_path []
  in
  List.iter (fun x -> Printf.printf "%i " x) listLength

(*test nom des arêtes enlevé *)
let _ =
  let graph =
    PGraph.list_to_graph
      [
        ('a', 1, 'b');
        ('a', 6, 'd');
        ('a', 8, 'e');
        ('b', 7, 'c');
        ('e', 2, 'g');
        ('b', 3, 'f');
        ('g', 4, 'c');
        ('f', 5, 'c');
        ('e', 6, 'c');
      ]
      PGraph.empty
  in
  let set_blacklist = PGraph.blacklisted_node 'a' 'c' graph in
  PGraph.NodeSet.iter (fun node -> Printf.printf "\n%c" node) set_blacklist

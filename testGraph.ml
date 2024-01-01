module PGraph = Graph.Make (Char)
module CharSet = Set.Make (Char)

(*
   a ---> b ----> c
   ^              |
   |--------------|
*)
let small_graph_1 =
  PGraph.list_to_graph_no_pond [('a', 'b'); ('b', 'c'); ('c', 'a')]

(*
   a ---> b ----> c
   |              ^
   |--------------|
*)
let small_graph_2 =
  PGraph.list_to_graph_no_pond [('a', 'b'); ('a', 'c'); ('b', 'c')]

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

let big_graph =
  PGraph.list_to_graph_no_pond
    [ ('a', 'b')
    ; ('a', 'd')
    ; ('a', 'e')
    ; ('b', 'c')
    ; ('e', 'g')
    ; ('b', 'f')
    ; ('g', 'c')
    ; ('f', 'c')
    ; ('e', 'c') ]

(*graph de la vidéo*)
let goal_graph =
  PGraph.list_to_graph
    [ ('s', 0, 5, 'a')
    ; ('a', 0, 10, 'b')
    ; ('b', 0, 10, 'c')
    ; ('c', 0, 5, 't')
    ; ('s', 0, 10, 'd')
    ; ('d', 0, 20, 'e')
    ; ('e', 0, 30, 'f')
    ; ('f', 0, 15, 't')
    ; ('s', 0, 15, 'g')
    ; ('g', 0, 25, 'h')
    ; ('h', 0, 20, 'f')
    ; ('h', 0, 10, 'i')
    ; ('i', 0, 10, 't') ]

let graph_file =
  PGraph.list_to_graph
    [ ('s', 0, 10, 's')
    ; ('s', 0, 10, 'a')
    ; ('s', 0, 5, 'b')
    ; ('b', 0, 7, 'e')
    ; ('a', 0, 4, 'b')
    ; ('a', 0, 3, 'c')
    ; ('c', 0, 7, 't')
    ; ('d', 0, 12, 't')
    ; ('e', 0, 28, 't') ]

let graph_a_b = PGraph.list_to_graph_no_pond [('a', 'b')]

let prettyPrint test nameOfTest commentaire =
  if test then
    Printf.printf "%s %s : OK \n" nameOfTest commentaire
  else
    Printf.printf "%s %s : NOT OK \n" nameOfTest commentaire

let pretty_print_all_shortest_paths setPath =
  Printf.printf "all_shortest_paths: \n" ;
  PGraph.SetOfPath.iter
    (fun path ->
      match path with
      | [] ->
          ()
      | (first_node, min, max) :: rest_of_path ->
          Printf.printf "Path: [%c,(%i ;%i)]" first_node min max ;
          List.iter
            (fun (node, min, max) ->
              Printf.printf " <-- [%c,(%i ;%i)]" node min max )
            rest_of_path ;
          Printf.printf "\n" )
    setPath

(******************** is_empty ************************)

(*test vacuité*)
let vacuite1 g =
  prettyPrint (PGraph.is_empty g) "test_is_empty" "test graph vide de base"

let _ = vacuite1 PGraph.empty

(******************** fold_node ************************)

(* pour tester le fold on va faire différentes opérations
   les noeuds pour voir s'il fonctionne *)

(* on va compter le nombre de noeud de différents graph*)

let test_fold_node g =
  let numFold = PGraph.fold_node (fun node acc -> acc + 1) g 0 in
  let numManualFold = PGraph.NodeMap.fold (fun node _ acc -> acc + 1) g 0 in
  prettyPrint (numFold = numManualFold) "test_fold_node" "fold_node fonctionne"

let _ = test_fold_node small_graph_1

(******************** fold_succs ************************)

(* compte le nombre d'arc *)
let test_fold_succs g =
  let numFold = PGraph.fold_succs (fun noeud ponderation acc -> acc + 1) g 0 in
  let numManualFold =
    PGraph.NodeMap.fold
      (fun _ succs acc -> PGraph.NodeMap.fold (fun _ _ acc -> acc + 1) succs acc)
      g 0
  in
  prettyPrint (numFold = numManualFold) "test_fold_succs" "graph avec 4 arc"

let _ = test_fold_succs small_graph_1

(******************** mem_node TEST ************************)

let _ =
  let result = PGraph.mem_node 'b' small_graph_1 in
  prettyPrint result "test_mem_node" "B in Graph "

(******************** mem_edge TEST ************************)
(* la fonction retourne une exception si n1 n'est pas dans le graph
   booléen sinon *)

(*test existent d'arête*)
let _ =
  prettyPrint
    (PGraph.mem_edge 'a' 'b' graph_a_b)
    "test_mem_edge" "A ---> B existe"

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
let _ =
  (* a est le successeur de b donc vrai *)
  let result = PGraph.mem_exist_as_successor 'b' small_graph_1 in
  prettyPrint result "test_mem_exist_as_successor"
    "A est le successeur d'un noeud"

(* test si le noeud b n'est pas un successeur*)
let _ =
  let graph = PGraph.list_to_graph_no_pond [('a', 'b'); ('a', 'c')] in
  (* b n'est le successeur de personne donc faux*)
  let result = PGraph.mem_exist_as_successor 'b' graph in
  prettyPrint result "test_mem_exist_as_successor"
    "B est le successeur d'aucun noeud"

(******************** succs TEST ************************)

let _ =
  (*
     dans la map on a donc 
    {a : {b : 1 }}
  *)
  (* on récupère le succeseur de a *)
  let successor_of_n1 = PGraph.succs 'a' graph_a_b in
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
  let a_vers_b = PGraph.mem_edge 'a' 'b' graph_a_b in
  let b_vers_a = PGraph.mem_edge 'b' 'a' graph_a_b in
  prettyPrint (a_vers_b && not b_vers_a) "test_edge"
    "A ---> B existe et A <---- B n'existe pas"

(******************** add_node TEST ************************)

(* test si le noeud demandé est rajouter ET connecter au noeud demandé

   avant : graph avec juste un noeud ex: 'a'
   après : a ---(1)---> b
*)
let _ =
  let node_created = PGraph.mem_node 'b' graph_a_b in
  prettyPrint node_created "test_add_node" "le nouveau noeud B existe"

(* test si l'arête a bien été crée*)
let _ =
  let edge_created = PGraph.mem_edge 'a' 'b' graph_a_b in
  prettyPrint edge_created "test_add_node" "l'arête A ---> B existe"

(* test qui vérifie que add_node 'a' 'a' ne crée pas une boucle*)
let _ =
  let graph = PGraph.list_to_graph_no_pond [('a', 'a')] in
  let graphWithCycle = PGraph.add_node 'a' 0 1 'a' graph in
  prettyPrint
    (PGraph.mem_edge 'a' 'a' graphWithCycle)
    "test_add_node" "A---> A n'existe pas "

(******************** remove_edge TEST ************************)

(* test qui vérifie si l'arête a bien été supprimer ,
   càd que n2 n'est plus dans les successeurs de n1 *)

let _ =
  let graph_two_lonely_node = PGraph.remove_edge 'a' 'b' graph_a_b in
  prettyPrint
    (not (PGraph.mem_edge 'a' 'b' graph_two_lonely_node))
    "test_remove_edge" "A ---> B n'existe plus"

(*test si malgré une boucle , A n'a pas été supprimé *)
let _ =
  let graph = PGraph.list_to_graph_no_pond [('a', 'a')] in
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
    PGraph.list_to_graph_no_pond [('a', 'b'); ('a', 'c'); ('c', 'b')]
  in
  let addedCycle = PGraph.add_default_edge 'b' 'b' graph in
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
  let graph = PGraph.list_to_graph_no_pond [('b', 'a'); ('c', 'a')] in
  let graphWithCycle = PGraph.add_default_edge 'a' 'a' graph in
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
    PGraph.list_to_graph_no_pond [('a', 'b'); ('b', 'c'); ('a', 'c')]
  in
  let final = PGraph.add_default_edge 'c' 'c' graph in
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
    PGraph.list_to_graph_no_pond [('a', 'b'); ('b', 'c'); ('a', 'c')]
  in
  let final = PGraph.add_default_edge 'c' 'c' graph in
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
    PGraph.list_to_graph_no_pond
      [ ('a', 'b')
      ; ('a', 'd')
      ; ('a', 'e')
      ; ('b', 'c')
      ; ('e', 'g')
      ; ('b', 'f')
      ; ('g', 'c')
      ; ('f', 'c')
      ; ('e', 'c') ]
  in
  (* test avec des cycles*)
  let addedCycles = PGraph.add_default_edge 'b' 'b' graph in
  (*test bfs*)
  let normallySameSet = PGraph.all_shortest_paths 'a' 'c' addedCycles in
  (*printing the whole set *)
  Printf.printf "all_shortest_paths: \n" ;
  pretty_print_all_shortest_paths normallySameSet

(******************** TEST dinic ************************)

(*test nombre de niveau*)

let _ =
  let graph =
    PGraph.list_to_graph_no_pond
      [ ('a', 'b')
      ; ('a', 'd')
      ; ('a', 'e')
      ; ('b', 'c')
      ; ('e', 'g')
      ; ('b', 'f')
      ; ('g', 'c')
      ; ('f', 'c')
      ; ('e', 'c') ]
  in
  let all_path = PGraph.all_shortest_paths 'a' 'c' graph in
  (*compte le nombre de niveau*)
  let listLength =
    (* on enlève -2 car le puit et la source sont dedans *)
    PGraph.SetOfPath.fold (fun l acc -> (List.length l - 2) :: acc) all_path []
  in
  List.iter (fun x -> Printf.printf "%i " x) listLength

(*test nom des arêtes enlevé *)
let _ =
  let set_blacklist = PGraph.blacklisted_node 's' 't' graph_file in
  PGraph.NodeSet.iter (fun node -> Printf.printf "\n%c" node) set_blacklist

(*test get_bottleneck *)

(* graph vidéo *)
(* la 1e etape fonctionne
   let _ =
     Printf.printf "\n\ntest graph goal_graph \n";
     let shortest = PGraph.all_shortest_paths 's' 't' goal_graph in
     Printf.printf "\nBefore applying bottleneck\n";
     pretty_print_all_shortest_paths shortest;
     let g =
       PGraph.SetOfPath.fold
         (fun path acc -> PGraph.apply_bottleneck (List.rev path) acc)
         shortest goal_graph
     in
     Printf.printf "\nAfter applying bottleneck\n";
     let newShortest = PGraph.all_shortest_paths 's' 't' g in
     pretty_print_all_shortest_paths newShortest;
     Printf.printf "\n";
     Printf.printf "flow_maximal : %i\n" (PGraph.get_max_flow 't' g)
*)

(* graph exo *)

(* test 1 itération*)
let _ =
  Printf.printf "\n\ntest graph graph_file \n" ;
  let shortest = PGraph.all_shortest_paths 's' 't' graph_file in
  Printf.printf "\nBefore applying bottleneck\n" ;
  pretty_print_all_shortest_paths shortest ;
  Printf.printf "\n" ;
  let g =
    PGraph.SetOfPath.fold
      (fun path acc ->
        (* printing list*)
        PGraph.apply_bottleneck (List.rev path) acc )
      shortest graph_file
  in
  Printf.printf "\n 1 iteration \n" ;
  let newShortest = PGraph.all_shortest_paths 's' 't' g in
  pretty_print_all_shortest_paths newShortest ;
  Printf.printf "\n" ;
  Printf.printf "flow_maximal : %i" (PGraph.get_max_flow 't' g)

(*test dinic *)
let _ =
  Printf.printf "\n\ntest dinic graph_file \n" ;
  let g = PGraph.dinic 's' 't' (PGraph.clean_graph 's' 't' graph_file) in
  Printf.printf "\n" ;
  PGraph.NodeMap.iter
    (fun node succs ->
      PGraph.NodeMap.iter
        (fun node2 (min, max) ->
          Printf.printf "%c -> %c : (%i,%i)\n" node node2 min max )
        succs )
    g ;
  Printf.printf "\n" ;
  Printf.printf "flow_maximal : %i" (PGraph.get_max_flow 't' g)

(*
   (* test clean_set
      semble fonctionner *)
   let _ =
     Printf.printf "\n\ntest clean_set \n";
     let shortest = PGraph.all_shortest_paths 's' 't' goal_graph in
     Printf.printf "\nBefore \n";
     pretty_print_all_shortest_paths shortest;
     let newSet = PGraph.clean_set shortest [ 'h'; 'a' ] in
     Printf.printf "\nAfter \n";
     pretty_print_all_shortest_paths newSet

   (*test chemin qui n'existe pas *)
   let _ =
     Printf.printf "\n\ntest chemin qui n'existe pas \n";
     let shortest = PGraph.all_shortest_paths 't' 's' goal_graph in
     Printf.printf "\n\n";
     pretty_print_all_shortest_paths shortest *)

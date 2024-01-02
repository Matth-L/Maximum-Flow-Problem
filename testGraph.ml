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

(* graph de l'énoncé*)
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

(****************************** print ********************************)

let pretty_print test nameOfTest commentaire =
  if test then
    Printf.printf "\027[32m\n%s %s : OK \n\027[0m" nameOfTest commentaire
  else
    Printf.printf "\027[31m\n%s %s : NOT OK \n\027[0m" nameOfTest commentaire

let pretty_print_all_shortest_paths setPath =
  Printf.printf "all_shortest_paths: \n" ;
  PGraph.SetOfPath.iter
    (fun path ->
      match path with
      | [] ->
          ()
      | (node, min, max) :: rest_of_path ->
          Printf.printf "Path: [%c,(%i ;%i)]" node min max ;
          List.iter
            (fun (node, min, max) ->
              Printf.printf " <-- [%c,(%i ;%i)]" node min max )
            rest_of_path ;
          Printf.printf "\n" )
    setPath

(******************** is_empty ************************)

(*test vacuité*)
let test_vacuite g =
  pretty_print (PGraph.is_empty g) "test_is_empty" "test graph vide de base"

(******************** fold_node ************************)

(* on va compter le nombre de noeud de différents graph*)
(* compte le nombre de noeud manuellement et implémenté *)

let test_fold_node g =
  let numFold = PGraph.fold_node (fun node acc -> acc + 1) g 0 in
  let numManualFold = PGraph.NodeMap.fold (fun node _ acc -> acc + 1) g 0 in
  pretty_print (numFold = numManualFold) "test_fold_node" "fold_node fonctionne"

(******************** fold_succs ************************)

(* compte le nombre d'arc  avec un fold manuel et implémenté , on vérifie
   si le même résulat est donnée*)
let test_fold_succs g =
  let numFold = PGraph.fold_succs (fun noeud ponderation acc -> acc + 1) g 0 in
  let numManualFold =
    PGraph.NodeMap.fold
      (fun _ succs acc -> PGraph.NodeMap.fold (fun _ _ acc -> acc + 1) succs acc)
      g 0
  in
  pretty_print (numFold = numManualFold) "test_fold_succs"
    "fold_succs fonctionne"

(******************** mem_node TEST ************************)

(* on choisi un noeud et regarde si le test fonctionne*)
let test_mem_node g =
  (* on choisi une clé dans le graph*)
  let node, succs = PGraph.NodeMap.choose g in
  let result = PGraph.mem_node node g in
  pretty_print result "test_mem_node" "node in graph "

(******************** mem_edge TEST ************************)

(* de même pour une arête*)
let test_mem_edge g =
  let node, succs = PGraph.NodeMap.choose g in
  let node2, ponderation = PGraph.NodeMap.choose succs in
  let result = PGraph.mem_edge node node2 g in
  pretty_print result "test_mem_edge" "edge in graph "

(******************** mem_exist_as_successor TEST ************************)

(* on fait dans le sens inverse on vérifie s'il est bien un succs*)
let test_mem_exist_as_successor g =
  let node, succs = PGraph.NodeMap.choose g in
  let node2, ponderation = PGraph.NodeMap.choose succs in
  let result = PGraph.mem_exist_as_successor node2 g in
  pretty_print result "test_mem_exist_as_successor"
    "node2 is a successor of a node"

(******************** succs TEST ************************)

let test_succs g =
  (* on prend le successeur d'un noeud avec la fonction et manuellement*)
  let node, succs = PGraph.NodeMap.choose g in
  let succsNode = PGraph.succs node g in
  let succsNodeManual = PGraph.NodeMap.find node g in
  let result = succsNode = succsNodeManual in
  pretty_print result "test_succs" "succs fonctionne"

(******************** add_lonely_node TEST ************************)

let test_add_lonely_node g =
  (* pour faire un set de test très générique
     il faudrait ajouter parmi la liste des noeuds
     qui ne sont pas dans le graph,
     mais je sais que les lettres de la fin de
     l'alphabet ne sont jamais utilisé dans mes test*)
  let newGraph = PGraph.add_lonely_node 'z' g in
  let result = PGraph.mem_node 'z' newGraph in
  pretty_print result "test_add_lonely_node" "add_lonely_node fonctionne"

(******************** add_edge TEST ************************)

let test_add_edge g =
  (* on prend a ---> b et on ajoute b ---> a *)
  let node, succs = PGraph.NodeMap.choose g in
  let node2, ponderation = PGraph.NodeMap.choose succs in
  let newGraph = PGraph.add_edge node2 0 1 node g in
  let result = PGraph.mem_edge node2 node newGraph in
  pretty_print result "test_add_edge" "add_edge fonctionne"

(******************** add_node TEST ************************)

(* test si le noeud demandé est rajouter ET connecter au noeud demandé

   avant : graph avec juste un noeud ex: 'a'
   après : a ---(1)---> b
*)

let test_add_node g =
  let nodeS = 'y' in
  let nodeG = 'z' in
  let newGraph = PGraph.add_node nodeS 0 1 nodeG g in
  (* y ----> z *)
  (* les 2 noeuds existe *)
  let node_S_exist = PGraph.mem_node nodeS newGraph in
  let node_G_exist = PGraph.mem_node nodeG newGraph in
  (* l'arête existe *)
  let edge_exist = PGraph.mem_edge nodeS nodeG newGraph in
  let result = node_S_exist && node_G_exist && edge_exist in
  pretty_print result "test_add_node" "add_node fonctionne"

(******************** remove_edge TEST ************************)

(* test qui vérifie si l'arête a bien été supprimer ,
   càd que n2 n'est plus dans les successeurs de n1 *)

let test_remove_edge g =
  let node, succs = PGraph.NodeMap.choose g in
  let succs, pond = PGraph.NodeMap.choose succs in
  let newGraph = PGraph.remove_edge node succs g in
  let result = not (PGraph.mem_edge node succs newGraph) in
  pretty_print result "test_remove_edge" "remove_edge fonctionne"

(******************** remove_node TEST ************************)

(* test qui vérifie si le noeud est bien enlevé du graph *)
let test_remove_node g =
  (* a existe à chaque fois dans les test*)
  let nodeWithoutA = PGraph.remove_node 'a' g in
  let result = not (PGraph.mem_node 'a' nodeWithoutA) in
  pretty_print result "test_remove_node" "remove_node fonctionne"

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
let number_of_incoming_edge =
  let graph =
    PGraph.list_to_graph_no_pond [('a', 'b'); ('b', 'c'); ('a', 'c')]
  in
  let final = PGraph.add_default_edge 'c' 'c' graph in
  let incoming_edge = PGraph.number_of_incoming_edge 'c' final in
  pretty_print (incoming_edge = 3) "test number_of_incoming_edge"
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
let number_of_outgoing_edge =
  let graph =
    PGraph.list_to_graph_no_pond [('a', 'b'); ('b', 'c'); ('a', 'c')]
  in
  let final = PGraph.add_default_edge 'c' 'c' graph in
  let outgoing_edge = PGraph.number_of_outgoing_edge 'a' final in
  pretty_print (outgoing_edge = 2) "test number_of_outgoing_edge "
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

let add_path =
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
  Printf.printf "all_shortest_paths: \n" ;
  pretty_print_all_shortest_paths normallySameSet ;
  pretty_print
    (PGraph.SetOfPath.cardinal normallySameSet = 2)
    "test_add_paths" "Il y a bien 2 chemin de A vers C "

(******************** get_flow ************************)

let test_get_flow g =
  let node, succs = PGraph.NodeMap.choose g in
  let node2, ponderation = PGraph.NodeMap.choose succs in
  let flow = PGraph.get_flow (node, node2) g in
  (* get flow manuellement*)
  let flowManual = PGraph.NodeMap.find node2 succs in
  let result = flow = flowManual in
  pretty_print result "test_get_flow" "get_flow fonctionne"

(******************** TEST dinic ************************)

(*test nom des arêtes enlevé *)
let _ =
  let set_blacklist = PGraph.blacklisted_node 's' 't' graph_file in
  pretty_print
    (PGraph.NodeSet.cardinal set_blacklist = 1)
    "\ntest_blacklisted_node" "Uniquement D à été enlevé"

(*test get_bottleneck *)
(* graph vidéo *)
(* la 1e etape fonctionne*)
let _ =
  Printf.printf "\n\ntest graph goal_graph \n" ;
  let shortest = PGraph.all_shortest_paths 's' 't' goal_graph in
  Printf.printf "\nBefore bottleneck\n" ;
  pretty_print_all_shortest_paths shortest ;
  let g =
    PGraph.SetOfPath.fold
      (fun path acc ->
        (* on applique le bottleneck sur la liste dans le bon sens*)
        PGraph.apply_bottleneck (List.rev path) acc )
      shortest goal_graph
  in
  Printf.printf "\nAfter bottleneck\n" ;
  let newShortest = PGraph.all_shortest_paths 's' 't' g in
  pretty_print_all_shortest_paths newShortest ;
  pretty_print
    (PGraph.get_maximum_flow_from_node 't' g = 30)
    "test_bottleneck" "Le flow maximal est bien de 30"

(* graph énoncé *)

(* test 1 itération*)
let _ =
  Printf.printf "\n\ntest graph graph_file \n" ;
  let shortest = PGraph.all_shortest_paths 's' 't' graph_file in
  Printf.printf "\nBefore bottleneck\n" ;
  pretty_print_all_shortest_paths shortest ;
  Printf.printf "\n" ;
  let g =
    PGraph.SetOfPath.fold
      (fun path acc -> PGraph.apply_bottleneck (List.rev path) acc)
      shortest graph_file
  in
  Printf.printf "\n 1 iteration \n\n" ;
  let newShortest = PGraph.all_shortest_paths 's' 't' g in
  pretty_print_all_shortest_paths newShortest ;
  Printf.printf "\n" ;
  pretty_print
    (PGraph.get_maximum_flow_from_node 't' g = 8)
    "test_bottleneck" "Le flow maximal est bien de 8 après 1 itération"

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
  pretty_print
    (PGraph.get_maximum_flow_from_node 't' g = 10)
    "test_dinic" "Le flow maximal est bien de 10 à la fin de l'algo"

(* test clean_set
   semble fonctionner *)
let _ =
  Printf.printf "\n\ntest clean_set \n" ;
  let shortest = PGraph.all_shortest_paths 's' 't' goal_graph in
  Printf.printf "\nBefore \n" ;
  pretty_print_all_shortest_paths shortest ;
  let newSet = PGraph.clean_set shortest ['h'; 'a'] in
  Printf.printf "\nAfter \n" ;
  pretty_print_all_shortest_paths newSet ;
  pretty_print
    (PGraph.SetOfPath.cardinal newSet = 1)
    "test_clean_set" "Il ne reste plus qu'un chemin"

(*test chemin qui n'existe pas *)
let _ =
  Printf.printf "\n\ntest chemin qui n'existe pas \n" ;
  let shortest = PGraph.all_shortest_paths 't' 's' goal_graph in
  Printf.printf "\n\n" ;
  pretty_print
    (PGraph.SetOfPath.cardinal shortest = 0)
    "test_chemin_inexistant" "Il n'y a pas de chemin de t vers s"

(************************ GENERIC SET OF TEST *********************************)
let all_test g =
  test_vacuite PGraph.empty ;
  test_fold_node g ;
  test_fold_succs g ;
  test_mem_node g ;
  test_mem_edge g ;
  test_mem_exist_as_successor g ;
  test_succs g ;
  test_add_lonely_node g ;
  test_add_edge g ;
  test_add_node g ;
  test_remove_edge g ;
  test_remove_node g ;
  test_get_flow g

let graph_list =
  [ ("small_graph_1", small_graph_1)
  ; ("small_graph_2", small_graph_2)
  ; ("big_graph", big_graph)
  ; ("graph_file", graph_file)
  ; ("goal_graph", goal_graph) ]

(* test pour tous les graph donnée au début du fichier
   qui sont dans la graph_list*)
let _ =
  List.fold_left
    (fun acc (name, g) ->
      Printf.printf "\n \nGraph : %s \n" name ;
      all_test g )
    () graph_list ;
  Printf.printf "\n\n"

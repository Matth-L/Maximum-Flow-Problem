(**
@file graph.ml
@brief implémentation d'un graph ordonnée 
*)

(* Exception pour les ensembles vides *)
exception EmptySet

(* Exception pour les dictionnaires vides *)
exception EmptyMap

(*
   Exemple 1 : 
   (A)      2        (B)
   |--------------->|
   |               /|
   |              / | 2
   |             /  |
   |            /   v
   |3        4 /   (C)
   |          /
   v         /
   (D)      /
   ^       /
   |      /
   |     /
   |1   /
   |   /
   |  /
   | v
   (E)

   {
    A : {B: 2}
    B : {C: 2};{E: 4}
    C : {}
    D : {}
    E : {D: 1}
    
    Les nodes sont de la forme int NodeMap.t car des élèves ne sont pas divisible 
   }
*)

module type S = sig
  module NodeMap : Map.S

  (* pour l'ensemble de la liste des chemins*)
  module SetOfPath : Set.S

  type graph
  type node

  (** Le graph vide *)
  val empty : graph

  (**********************  LIST TO GRAPH FUNCTION *****************************)

  (**
  @requires une node list
  @ensures un graph ou il y a des edges entre plusieurs noeuds.
  @raises rien 
  *)
  val list_to_graph : (node * 'a * 'b * node) list -> graph

  (**
  @requires une node list
  @ensures un graph ou il y a des edges entre plusieurs noeuds.
  @raises rien
  *)
  val list_to_graph_no_pond : (node * node) list -> graph

  (**********************  BOOLEAN FUNCTION ***********************************)

  (**
  @requires Rien 
  @ensures True si graph vide, False sinon 
  @raises Rien 
  *)
  val is_empty : graph -> bool

  (**********************  SUCCS FUNCTION ***********************************)

  (**
  @requires le noeud node appartient au graph 
  @ensures un ensemble correspondant au successeur du noeud 
  passé en paramètre, si le noeud n'a pas de successeur, on retourne un ensemble vide
  @raises rien
  *)
  val succs : node -> graph -> 'a NodeMap.t

  (**********************  FOLD FUNCTION ***********************************)

  (*
     Map.fold
     val fold : (key -> 'a -> 'acc -> 'acc) -> 'a t -> 'acc -> 'acc
  *)

  (**
  @requires un graph
  @ensures un fold sur le graph
  @raises Rien
  *)
  val fold_node : (node -> 'a -> 'a) -> graph -> 'a -> 'a

  (**
  @requires un graph
  @ensures un fold sur les successeurs du noeud
  @raises Rien
  *)
  val fold_succs : (node -> 'a * 'b -> 'c -> 'c) -> graph -> 'c -> 'c

  (**********************  MEM FUNCTION ***********************************)

  (**
  @requires Rien 
  @ensures un booléen indiquant si le noeud est dans le graph
  @raises Rien
  *)
  val mem_node : node -> graph -> bool

  (**
  @requires que n1 appartiennent au graph 
  @ensures un booléen indiquant si n1 ---------> n2
  @raises rien 
  *)
  val mem_edge : node -> node -> graph -> bool

  (**
  @requires un noeud 
  @ensures un booléen indiquant si node est un successeurs d'un élement dans le graph
  @raises rien 
  *)
  val mem_exist_as_successor : node -> graph -> bool

  (**********************  ADDING FUNCTION ***********************************)

  (**
  @requires un noeud
  @ensures l'ajout d'un noeud au graph, relié rien ,
  uniquement si le noeud n'existe pas déjà 
  @raises Rien
  *)
  val add_lonely_node : node -> graph

  (**
  @brief Fonction qui prend 2 noeud existant et qui lie le noeud A 
  au noeud B avec la pondération (min,max) 
  @requires les 2 noeuds existent 
  @ensures la création d'une arête entre les 2 noeuds
  @raises failwith si les 2 noeuds n'existe pas 
  *)
  val add_edge : node -> int -> int -> node -> graph -> graph

  (**
  @brief Fonction qui prend 2 noeud, les crée si ils n'existent pas
  et les lie entre eux avec la pondération (min,max)
  @requires rien 
  @ensures La création de 2 noeuds et d'une arête entre les 2
  @raises Rien car les 2 noeuds sont crée, le test de add_edge
  n'est pas censé retourner une erreur
  @example add_node (B) 2 (C) (G) 
  B ----------- 2 ---------> C 
  *)
  val add_node : node -> int -> int -> node -> graph -> graph

  (**
  @brief Même fonction que pour add_edge mais pour les graphe non pondéré 
  (toutes les pondérations sont à (0,1) )
  @requires les 2 noeuds existent 
  @ensures la création d'une arête entre les 2 noeuds
  @raises failwith si les 2 noeuds n'existe pas
  *)
  val add_default_edge : node -> graph

  (**
  @brief Même fonction que add_node mais dans un cas non pondéré
  @requires que le noeud existe dans le graph 
  @ensures, l'ajout d'un noeud de pondération n , successeur du noeud
  donnée en paramètre 
  @raises EmptyMap si le noeud en paramètre n'existe pas
  *)
  val add_default_node : node -> node -> graph -> graph

  (**********************  REMOVE FUNCTION ********************************)

  (**
  @requires les 2 nodeuds 
  @ensures que l'arête 1 ------> 2 soit supprimer 
  @raises failwith si les 2 noeuds n'existe pas
  @warning si A ---> A , on supprime l'arête mais pas le noeud
  *)
  val remove_edge : node -> node -> graph -> graph

  (**
  @requires les 2 nodeuds 
  @ensures que l'arête 1 -----> 2 ET 2 --------> 1
  @raises failwith si les 2 noeuds n'existe pas (voir remove_edge)
  *)
  val remove_edges : node -> node -> graph -> graph

  (**
  @requires le noeud à récupérer ainsi que le graph 
  @ensures que le noeud soit bien retirer du graph ainsi que les noeuds qui pointent vers lui
  @raises Rien
  *)
  val remove_node : node -> graph -> graph

  (**********************  COUNTING FUNCTION ********************************)

  (**
  @requires un noeud existant dans graph
  @ensures le nombre d'arc
  @raises le noeud n'est pas dans le graph

  a ----> b 
  c ----> b 

  number_of_incoming_edge 'b' graph ===> 2 

  *)
  val number_of_incoming_edge : node -> graph -> int

  (**
  @requires un noeud existant dans graph
  @ensures le nombre d'arc
  @raises le noeud n'est pas dans le graph

  a ----> b 
  a-----> c
  a-----> a
  c ----> b 

  number_of_outgoing_edge 'a' graph ===> 3

  *)
  val number_of_outgoing_edge : node -> graph -> int

  (*NON TESTER*)

  (**
  @requires un graph
  @ensures un ensemble de chemin correspondant à tous les chemins possible dans le graphe au rang suivant 
  @raises Rien
  *)
  val add_paths_to_set : SetOfPath.t -> graph -> SetOfPath.t

  (**
  @requires un graph
  @ensures un ensemble de chemin correspondant à tous les chemins possible dans le graphe
  @raises Rien
  *)
  val add_paths_to_set_while_possible : SetOfPath.t -> graph -> SetOfPath.t
end

(************************************************************************)
(************************************************************************)
(************************************************************************)
(**********************  IMPLEMENTATION  ********************************)
(************************************************************************)
(************************************************************************)
(************************************************************************)

module Make (X : Map.OrderedType) = struct
  module NodeMap = Map.Make (X)
  module NodeSet = Set.Make (X)

  type node = NodeMap.key
  type graph = (int * int) NodeMap.t NodeMap.t

  let empty = NodeMap.empty
  let is_empty g = NodeMap.is_empty g

  (***********  let ***********  SUCCS FUNCTION ***********************************)

  let succs n g =
    (*si le noeud appartient au graph,
      on retourne la clé , sinon on retourne rien*)
    try NodeMap.find n g with Not_found -> NodeMap.empty

  (**********************  FOLD FUNCTION ***********************************)

  (*
  le fold n'est fait que sur les clé, donc les noeuds (from)
  *)
  let fold_node f g v0 =
    NodeMap.fold (fun currNode _ acc -> f currNode acc) g v0

  (*
     Lors du fold, pour chaque clé, on va faire un fold sur les successeurs
     a --> b 
     b --> c
     c --> a 
     a --> c
     { a : {
       b: 1 ; 
       c: 1
       }
       b : {c: 1}
       c : {a: 1}
     }
     l'un des élement qui recevra la fonction f sera b et c du noeud a par ex
     *)
  let fold_succs f g acc =
    NodeMap.fold
      (fun noeud successeur acc1 ->
        NodeMap.fold
          (fun noeudSuccs (min, max) acc2 -> f noeudSuccs (min, max) acc2)
          successeur acc1)
      g acc

  (********************** MEM FUNCTION ***********************************)

  let mem_node n g = NodeMap.mem n g

  let mem_edge n1 n2 g =
    (* n1 -----> n2 ? true : false *)
    if mem_node n1 g then
      let succs_of_n1 = succs n1 g in
      NodeMap.mem n2 succs_of_n1
    else
      false

  let mem_exist_as_successor n g =
    if mem_node n g then
      NodeMap.fold (fun noeud valeur acc -> acc || NodeMap.mem n valeur) g false
    else
      false

  (**********************  ADDING FUNCTION ***********************************)

  (* ajoute un noeud au graphe, qui n'est relié à rien *)
  let add_lonely_node n g =
    if mem_node n g then
      (* si un noeud existe déjà, il n'est pas ajouté au graph *)
      g
    else
      (*sinon on l'ajoute*)
      NodeMap.add n NodeMap.empty g

  (* fais : n1 ----- (min, max) ----> n2 ; si n1 et n2 existe dans le graph *)
  let add_edge n1 min max n2 g =
    (*si les 2 noeuds existent dans le graph*)
    if mem_node n1 g && mem_node n2 g then
      (*on récupère les successeurs de n1 *)
      let successor_of_n1 = succs n1 g in
      (*on ajoute n2 à la liste des successeurs de n1*)
      let updated_succs = NodeMap.add n2 (min, max) successor_of_n1 in
      (* on met à jour la clé *)
      NodeMap.add n1 updated_succs g
    else
      failwith "add_edge : les noeuds nécessaires n'existent pas "

  (* ajoute 2 noeuds et les relies entre eux *)
  let add_node n1 min max n2 g =
    let graph_with_n1 = add_lonely_node n1 g in
    let graph_with_both_node = add_lonely_node n2 graph_with_n1 in
    add_edge n1 min max n2 graph_with_both_node

  (* cas des graphe non pondérés *)
  let add_default_edge n1 n2 g = add_edge n1 0 1 n2 g

  (* cas des graphe non pondérés *)
  let add_default_node n1 n2 g = add_node n1 0 1 n2 g

  (**********************  REMOVE FUNCTION ***********************************)

  let remove_edge n1 n2 g =
    if mem_node n1 g && mem_node n2 g then
      (*on supprime l'arête n1 -----> n2 *)
      let successor_of_n1 = succs n1 g in
      let updated_successor_of_n1 = NodeMap.remove n2 successor_of_n1 in
      NodeMap.add n1 updated_successor_of_n1 g
    else
      failwith "remove_edge : les 2 noeuds n'existent pas"

  let remove_edges n1 n2 g =
    let graph_unlink_n1_to_n2 = remove_edge n1 n2 g in
    let graph_unlink_n2_to_n1 = remove_edge n2 n1 graph_unlink_n1_to_n2 in
    graph_unlink_n2_to_n1

  let remove_node n g =
    let graph_without_successor_to_n =
      (* pour le dictionnaire de successeurs, on applique remove,
         afin d'enlever la clé n ,
         et on ajoute cette nouvelle map à la clé , ce qui
         met donc à jour ses successeurs*)
      NodeMap.fold
        (fun noeud valeur acc ->
          NodeMap.add noeud (NodeMap.remove n valeur) acc)
        g NodeMap.empty
    in
    NodeMap.remove n graph_without_successor_to_n

  (********************  COUNTING FUNCTION *********************************)

  (* nombre d'arc qui pointe vers le noeud*)
  let number_of_incoming_edge n g =
    if not (mem_node n g) then
      failwith "number_of_incoming_edge : le noeud n'existe pas"
    else
      fold_succs
        (fun node _ acc ->
          if node = n then
            acc + 1
          else
            acc)
        g 0

  (* nombre d'arc qui quitte le noeud, c'est donc le nombre de successeurs*)
  let number_of_outgoing_edge (n : node) (g : graph) =
    if not (mem_node n g) then
      failwith "number_of_outgoing_edge : le noeud n'existe pas"
    else
      let map_of_succs = succs n g in
      NodeMap.cardinal map_of_succs

  (******************** GETTER FUNCTION ****************************)
  let get_flow (n1, n2) g =
    if mem_edge n1 n2 g then
      let succs_of_n1 = succs n1 g in
      let min, max = NodeMap.find n2 succs_of_n1 in
      (min, max)
    else
      failwith "get_flow : l'arête n'existe pas"

  (******************** SETTER FUNCTION ****************************)

  (********************  LIST TO GRAPH FUNCTION ****************************)

  (* crée les noeuds ainsi que le lien entre start et finish
     goal :
     [(a,1,2,b);(a,3,4,c)]
     a --(1,2)---> b
     |
     |----(3,4)----> c
  *)

  let list_to_graph (l : (node * int * int * node) list) : graph =
    List.fold_right
      (fun (start, min, max, finish) acc -> add_node start min max finish acc)
      l empty

  let list_to_graph_no_pond l =
    List.fold_right
      (fun (start, finish) acc -> add_node start 0 1 finish acc)
      l empty

  (***********************************************************)
  (******************** Phase 1 ******************************)
  (***********************************************************)

  (**

  BUT : partir de a , trouver l'ensemble des plus court chemins

              |-----> f
              |
      a ----> b ----> c
      |               ^
      |-----> d       |
      |               |
      |-----> e ----> g
      
      1)
      
      [
        
        [(b,1)]
        [(d,1)]
        [(e,1)]
        
        ]
      2)
      focus sur [(b,1)]
      [b,1] =>
      
      [
        
        [(c,1);(b,1)]
        [(f,1);(b,1)]
        
        ]
        
        puis on remplace (b,1) par le nouveau chemin
      [
        
        [(c,1);(b,1)]
        [(f,1);(b,1)]
        [(d,1)]
        [(e,1)]
        
        ]
        **)

  (********************  Ensemble chemin *********************************)

  (*
    pour stocker les chemins, on va utiliser des ensembles,
    cela permet de ne pas se faire avoir par l'ordre et de fold
    sans prendre en compte du sens dans lequel on lit
  *)
  module SetOfPath = Set.Make (struct
    type t = (node * int * int) list

    let compare = compare
  end)

  (*
  ex ensemble : 
 {
  [(a,1);(b,1)]
  [(d,1)]
  [(e,1)]
 }    
  *)

  (* fonction qui ajoute tous les chemins dans un ensemble de chemin *)
  let add_paths_to_set ensInit g =
    (* on fold dans l'ensemble des chemins*)
    SetOfPath.fold
      (fun listOfPath acc1 ->
        (* on parcours chaque liste correspondant à un chemin*)
        (* on récupère le dernier noeud du chemin*)
        let n, min, max = List.hd listOfPath in
        (*on récupère ses successeurs*)
        let succs_of_n = succs n g in
        (*on fold sur tous les successeurs pour les ajouter à l'ensemble des chemins*)
        NodeMap.fold
          (* on ajoute le nouveau chemin à l'ensemble des chemin*)
            (fun nodeSuccessor (min, max) acc2 ->
            (* on vérifie si le noeud est déja la , pour ça il suffit de regarde si la tête c'est le même ça prend moins de temps qu'un mem *)
            let newPath =
              if List.hd listOfPath = (nodeSuccessor, min, max) then
                listOfPath
              else
                (nodeSuccessor, min, max) :: listOfPath
            in
            SetOfPath.add newPath acc2)
          succs_of_n acc1)
      ensInit ensInit

  (* fonction qui tant que les élément dans le SetOfPath ont des successerus, appel add_paths_to_set *)
  (* cela permet de remplir l'ensemble de tous les chemins possibles*)
  let rec add_paths_to_set_while_possible ensInit g =
    (* on ajoute les chemins tant que c'est possible*)
    let newSetOfPath = add_paths_to_set ensInit g in
    (* si le nouveau set est différent du set de base, on rappel la fonction*)
    if not (SetOfPath.equal ensInit newSetOfPath) then
      add_paths_to_set_while_possible newSetOfPath g
    else
      newSetOfPath

  (* maintenant, il suffit de prendre un noeud de départ et d'appliquer la fonction pour avoir l'ensemble avec tous les chemins allant de start vers goal *)
  let all_path start goal g =
    (* on transforme le noeud en ensemble*)
    let startingSet = SetOfPath.singleton [ (start, 0, 0) ] in

    (* on applique la fonction, on a donc tous les chemins possible du graph*)
    let allSet = add_paths_to_set_while_possible startingSet g in

    (* il suffit de remove ceux qui ne commence pas par goal ,
       le plus récent est la tête de la liste il suffit de regarder
       la tête *)
    SetOfPath.filter
      (fun listOfPath ->
        let n, min, max = List.hd listOfPath in
        n = goal)
      allSet

  (* fonction qui trouve le plus petit chemin à partir d'un ensemble*)
  let shortestOfSet set =
    (*fold sur l'ensemble*)
    SetOfPath.fold
      (fun listOfPath acc ->
        (* on regarde s'il y a plus court*)
        if List.length listOfPath < acc then
          List.length listOfPath
        else
          acc)
      set
      (* on commence en prenant la taille du premier set*)
      (List.length (SetOfPath.choose set))

  (* fonction qui prend tous les chemins dans un ensemble, trouve le plus cours, et filtre afin de garder tout ceux égal au plus court*)
  let allShortestPaths start goal g =
    let allPath = all_path start goal g in
    let shortest = shortestOfSet allPath in
    SetOfPath.filter
      (fun listOfPath -> List.length listOfPath = shortest)
      allPath

  (***********************************************************)
  (***********************************************************)
  (******************** phase 2 ******************************)
  (***********************************************************)
  (***********************************************************)

  (***********************************************************)
  (******************** V0 : naive ***************************)
  (***********************************************************)

  (* but : la fonction allPath nous donne un ensemble de chemin ou la pondération est marqué
     pour chaque chemin, on va donc prendre cette ensemble, transformé chaque liste d'ensemble en couple
     càd que si l'ensemble était
     couteux car fold sur chaque élement
     {
       [chemin A]
       [chemin B]
       [chemin C]
       [chemin D]
       }
       =>
       {
         (sum_ponderation_A , [chemin A])
         (sum_ponderation_B , [chemin B])
         (sum_ponderation_C , [chemin C])
         (sum_ponderation_D , [chemin D])
         }
  *)
  module SetOfPhase2 = Set.Make (struct
    type t = int * (node * int * int) list

    let compare = compare
  end)

  (**
  @requires une liste de chemin sous la forme [(a,1) ; (b,2)] ... 
  @ensures  de calculer le nombre total de la pondération d'un trajet 
  @raises rien
  *)
  let total_pond l = List.fold_right (fun (n, min, max) acc -> acc + max) l 0

  (**
  prend un ensemble de chemin et le transforme en ensemble ou chaque élément est un couple de la forme
  (sommePonderationChemin,[chemin])
  @requires un ensemble de chemin
  @ensures un ensemble de chemin avec la somme des pondérations facilement accessible
  @raises rien 
  *)
  let ponderation_of_set ens =
    SetOfPath.fold
      (fun listOfPath acc ->
        SetOfPhase2.add (total_pond listOfPath, listOfPath) acc)
      ens SetOfPhase2.empty

  (*prend le plus chemin avec la plus grosse pondération *)
  let sizeLongestPath ens =
    SetOfPhase2.fold
      (fun (pond, l) acc ->
        if pond > acc then
          pond
        else
          acc)
      ens 0

  (* filtre qui donnne tous les chemins qui ont la taille supérieur *)
  let longestPath ens =
    let sizeOfLongest = sizeLongestPath ens in
    SetOfPhase2.filter (fun (n, l) -> n = sizeOfLongest) ens

  (***********************************************************)
  (******************** V1 : dinic ***************************)
  (***********************************************************)

  (* https://www.youtube.com/watch?v=M6cm8UeeziI *)

  (* Pour connaitre le nombre de niveau il faut faire un BFS *)
  (* Les arêtes qui font passer du niveau N+1 au niveau N doivent être retirées du graphe. *)
  (* Les arêtes qui reste du niveau N au niveau N aussi *)

  (* Etape 1 : Construire le graphe de niveau en faisant un BFS de la source à la destination. un graph par niveau est un sous ensemble d'arête
     Etape 2 : Si le puit n'a jamais été atteint retourner le graph , c'est le graph de flow max
     Etape 3 : En utilisant seulement les arêtes valides, faire plusieurs DFS jusqu'a atteindre le flot bloquant
     La somme des flots bottleneck est le flot max *)

  (*les niveaux se font uniquement à partir des chemins les plus courts
    vers le puits, ils font donc faire la liste des noeuds qui n'en font
    pas partie,
    à la fin on a un ensemble de tous les noeuds qui ne font pas partie des plus courts chemins*)
  let blacklisted_node start goal g =
    (* on créer un ensemble qui contient tous les noeuds du graph *)
    let set_of_all_node =
      fold_node (fun node acc -> NodeSet.add node acc) g NodeSet.empty
    in
    let set_shortest_path = allShortestPaths start goal g in
    (* on crée un ensemble qui contient tous les noeuds du plus petit*)
    let set_of_node_shortest_path =
      SetOfPath.fold
        (fun listOfPath acc ->
          List.fold_right
            (fun (node, min, max) acc -> NodeSet.add node acc)
            listOfPath acc)
        set_shortest_path NodeSet.empty
    in
    NodeSet.diff set_of_all_node set_of_node_shortest_path

  (* but

     Pour chaque chemin dans l'ensemble des chemins les plus courts
     - Parcourir de source à destination, en utilisant uniquement les arêtes valides
     si on atteint la destination, on met le poids de toutes les arêtes par lequel on
     est passé à jour, c'est à dire au flot bloquant (puis blacklist les noeuds empruntés)
     - On s'arrête quand on ne peut plus atteindre la destination par des arêtes
     qui n'ont pas déja été utilisé (regarder si le noeud est dans la blacklist)
     - On recommence l'algorithme seulement sur les arêtes ou false
  *)

  (* fonction qui prend un graph et enlève les noeuds qui ne font pas partie du plus court chemin  pour avoir un graph de niveau  correct *)
  let clean_graph start goal g =
    let blacklisted = blacklisted_node start goal g in
    NodeSet.fold (fun node acc -> remove_node node acc) blacklisted g

  (* maintenant, il faut prendre un chemin, qu va de start à goal
     prendre le minimum de flow disponible pdt se trajet, mettre à jour le graph, et retourner le graph, si le flot min est plus petit que ce que l'on cherche à inscrire, une fois qu'une *)

  let get3rd (n1, n2, n3) = n3

  (* fonction qui prend un chemin et qui retourne le flot bottleneck *)
  (* il faut trouver le plus petit max de la liste *)
  let get_bottleneck l =
    List.fold_left
      (fun acc (n1, min, max) ->
        if max < acc || max != 0 then
          max
        else
          acc)
      (get3rd (List.hd l))
      l

  (* s'il y a un flot bloquant, on arrête, il faut donc pouvoir en répérer un *)

  (**
  @warning list_of_path est dans le bon sens  
  *)
  let there_is_blocking_flow list_of_path g =
    let rec aux l =
      match l with
      | [] | [ _ ] -> false (* on a besoin de 2 noeud pour avoir le flot*)
      (* il faut regarder dans le graph car les informations des liste ne sont peut être plus à jour *)
      | (n1, min1, max1) :: (n2, min2, max2) :: t ->
          let min, max = get_flow (n1, n2) g in
          if min = max then
            true
          else
            aux ((n2, min2, max2) :: t)
    in
    aux list_of_path

  let change_flow n1 n2 min max g =
    let succs_of_n1 = succs n1 g in
    let new_succs_n1 = NodeMap.add n2 (min, max) succs_of_n1 in
    NodeMap.add n1 new_succs_n1 g

  (* en appliquant le bottleneck à la liste à l'envers, donc de start à goal, on le parcourt également, si on sature une arête on la supprime du graphe , on refait l'ensemble à partir de ça et on recommence ? *)

  (**
  @warning list_of_path est dans le bon sens
  *)
  let apply_bottleneck list_of_path g =
    if there_is_blocking_flow list_of_path g then
      g
    else
      (* il n'y a aucun flot bloquant la ou on se situe*)
      let bneck = get_bottleneck list_of_path in
      Printf.printf "bottleneck : %d\n" bneck;
      (* on applique le bottleneck à toutes les arêtes *)
      let rec aux l graphAux =
        match l with
        | (n1, min1, max1) :: (n2, min2, max2) :: t ->
            (* on change la valeur du flow *)
            let newG = change_flow n1 n2 bneck max2 graphAux in
            (* on applique aux élements d'après *)
            aux ((n2, min2, max2) :: t) newG
        | [] | [ _ ] -> graphAux
      in
      aux list_of_path g

  (* une itération est faite, il faut maintenant supprimer les arêtes *)

  let clean_graph_of_saturated_edge g =
    NodeMap.fold
      (fun noeudStart succs acc ->
        NodeMap.fold
          (fun noeudEnd (min, max) acc1 ->
            if min = max then
              remove_edge noeudStart noeudEnd acc1
            else
              acc1)
          succs acc)
      g g
end

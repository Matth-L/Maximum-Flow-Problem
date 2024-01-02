(**
@file graph.ml
@author Lapu Matthias
@warning Comments are in french
*)

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
    A : {B: (0,2)}
    B : {C: (0,2)};{E: (0,4)}
    C : {}
    D : {}
    E : {D: (0,1)}
    
    Les nodes sont de la forme (int*int) NodeMap.t car des élèves 
    ne sont pas divisible 
   }
*)

module type S = sig
  module NodeMap : Map.S

  module NodeSet : Set.S

  (** pour stocker les différents chemins utilisé,
      on va utiliser des ensembles, cela est plus pratique
      et permet d'avoir accès à des fonctions utiles (ex : fold) *)
  module SetOfPath : Set.S

  (** le type du graph (voir plus haut schéma) *)
  type graph

  (** le type des noeuds *)
  type node

  (** Le graph vide *)
  val empty : graph

  (**********************  SUCCS FUNCTION ***********************************)

  (**
    @requires Rien
    @ensures un ensemble correspondant au successeur du noeud 
    passé en paramètre, si le noeud n'a pas de successeur, 
    on retourne un ensemble vide
    @raises rien
    *)
  val succs : node -> 'a NodeMap.t NodeMap.t -> 'a NodeMap.t

  (************************** BOOL FUNCTION ***********************************)

  (**
  @requires Rien 
  @ensures True si graph vide, False sinon 
  @raises Rien 
  *)
  val is_empty : graph -> bool

  (**
  @requires Rien 
  @ensures un booléen indiquant si le noeud est dans le graph
  @raises Rien
  *)
  val mem_node : node -> 'a NodeMap.t -> bool

  (**
  @requires Rien
  @ensures un booléen indiquant si n1 ---------> n2
  @raises rien 
  @warning si n1 n'existe pas dans le graph, on retourne false
  *)
  val mem_edge : node -> node -> 'a NodeMap.t NodeMap.t -> bool

  (**
  @requires Rien
  @ensures un booléen indiquant si node est un successeurs d'un 
  élement dans le graph
  @raises rien 
  *)
  val mem_exist_as_successor : node -> 'a NodeMap.t NodeMap.t -> bool

  (**
  @requires un noeud et un ensemble de chemin
  @ensures un booléen indiquant si le noeud est dans l'ensemble
  @raises Rien
  @brief dans set_of_path les listes sont de la forme (n,min,max)
  *)
  val mem_set_of_path : node -> (node * 'a * 'b) list -> bool

  (**********************  FOLD FUNCTION ***********************************)

  (*
     Map.fold
     val fold : (key -> 'a -> 'acc -> 'acc) -> 'a t -> 'acc -> 'acc
  *)

  (**
  @requires un graph , une fonction qui traite les noeuds 
  @ensures un fold sur le graph
  @raises Rien
  *)
  val fold_node : (node -> 'a -> 'a) -> 'b NodeMap.t -> 'a -> 'a

  (**
  @requires un graph, une fonction qui traite les successeurs
  @ensures un fold sur les successeurs du noeud
  @raises Rien
  *)
  val fold_succs :
    (node -> 'a * 'b -> 'c -> 'c) -> ('a * 'b) NodeMap.t NodeMap.t -> 'c -> 'c

  (***********************  ADDING FUNCTION ***********************************)

  (**
  @requires un noeud
  @ensures l'ajout d'un noeud au graph, relié rien ,
  uniquement si le noeud n'existe pas déjà 
  @raises Rien
  *)
  val add_lonely_node : node -> 'a NodeMap.t NodeMap.t -> 'a NodeMap.t NodeMap.t

  (**
  @brief Fonction qui prend 2 noeud existant et qui lie le noeud A 
  au noeud B avec la pondération (min,max) 
  @requires les 2 noeuds existent 
  @ensures la création d'une arête entre les 2 noeuds
  @raises failwith si les 2 noeuds n'existe pas
  *)
  val add_edge :
       node
    -> 'a
    -> 'b
    -> ('a * 'b) NodeMap.t NodeMap.t
    -> ('a * 'b) NodeMap.t NodeMap.t

  (**
  @brief Fonction qui prend 2 noeud, les crée si ils n'existent pas
  et les lie entre eux avec la pondération (min,max)
  @requires rien 
  @ensures La création de 2 noeuds et d'une arête entre les 2
  @raises Rien car les 2 noeuds sont crée, le test de add_edge
  n'est pas censé retourner une erreur
  @example add_node B 0 2 C G 
  B ----------- (0,2) ---------> C 
  *)
  val add_node :
       node
    -> 'a
    -> 'b
    -> node
    -> ('a * 'b) NodeMap.t NodeMap.t
    -> ('a * 'b) NodeMap.t NodeMap.t

  (**
  @brief Même fonction que pour add_edge mais pour les graphe non pondéré 
  (toutes les pondérations sont à (0,1) )
  @requires les 2 noeuds existent 
  @ensures la création d'une arête entre les 2 noeuds
  @raises failwith si les 2 noeuds n'existe pas (voir add_edge)
  *)
  val add_default_edge :
       node
    -> node
    -> (int * int) NodeMap.t NodeMap.t
    -> (int * int) NodeMap.t NodeMap.t

  (**
  @brief Même fonction que add_node mais dans un cas non pondéré
  @requires que le noeud existe dans le graph 
  @ensures, l'ajout d'un noeud de pondération n , successeur du noeud
  donnée en paramètre 
  @raises Rien
  *)
  val add_default_node :
       node
    -> node
    -> (int * int) NodeMap.t NodeMap.t
    -> (int * int) NodeMap.t NodeMap.t

  (**************************  REMOVE FUNCTION ********************************)

  (**
  @requires les 2 noeuds 
  @ensures que l'arête 1 ------> 2 soit supprimer 
  @raises failwith si les 2 noeuds n'existe pas
  @warning si A ---> A , on supprime l'arête mais pas le noeud
  *)
  val remove_edge :
    node -> node -> 'a NodeMap.t NodeMap.t -> 'a NodeMap.t NodeMap.t

  (**
  @requires les 2 nodeuds 
  @ensures que l'arête 1 -----> 2 ET 2 --------> 1
  @raises failwith si les 2 noeuds n'existe pas (voir remove_edge)
  *)
  val remove_edges :
    node -> node -> 'a NodeMap.t NodeMap.t -> 'a NodeMap.t NodeMap.t

  (**
  @requires le noeud à supprimer 
  @ensures que le noeud soit bien retirer du graph ainsi que les noeuds 
  qui pointent vers lui.
  Si le noeud n'existe pas, on retourne le graph inchangé
  @raises Rien
  *)
  val remove_node : node -> 'a NodeMap.t NodeMap.t -> 'a NodeMap.t NodeMap.t

  (************************* COUNTING FUNCTION ********************************)

  (**
  @requires un noeud existant 
  @ensures le nombre d'arc pointant vers le noeud
  @raises le noeud n'est pas dans le graph

  a ----> b 
  c ----> b 

  number_of_incoming_edge 'b' graph ===> 2 

  *)
  val number_of_incoming_edge : node -> ('a * 'b) NodeMap.t NodeMap.t -> int

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
  val number_of_outgoing_edge : node -> 'a NodeMap.t NodeMap.t -> int

  (**************************  GETTER FUNCTION ********************************)

  (**
  @requires 2 noeuds lié dans le graph
  @ensures le flot entre les 2 noeuds
  @raises les 2 noeuds ne sont pas lié dans le graph
  *)
  val get_flow : node * node -> ('a * 'b) NodeMap.t NodeMap.t -> 'a * 'b

  (********************* LIST_TO_GRAPH FUNCTION *******************************)

  (**
  @requires une node list
  @ensures la création d'un graph en fonction d'une liste de noeud 
  avec des pondérations
  @raises rien 
  *)
  val list_to_graph :
    (node * 'a * 'b * node) list -> ('a * 'b) NodeMap.t NodeMap.t

  (**
  @requires une node list
  @ensures la création d'un graph en fonction d'une liste de noeud 
  sans pondération (car toutes les pondérations sont à (0,1))
  @raises rien
  *)
  val list_to_graph_no_pond :
    (node * node) list -> (int * int) NodeMap.t NodeMap.t

  (****************************************************************************)
  (****************************************************************************)
  (***************************** Phase 1 **************************************)
  (****************************************************************************)
  (****************************************************************************)

  (*********************** Ensemble de chemin *********************************)

  (**
  @requires un ensemble de chemin et un graph 
  @ensures un ensemble de chemin correspondant à tous les chemins possible 
  dans le graphe au rang suivant 
  @raises Rien
  @warning les chemins sont du sens du plus récent ajouté donc dans le sens 
  inverse de lecture
  @warning seulement les chemins qui ne sont pas saturé sont ajouté
  *)
  val add_paths_to_set :
    SetOfPath.t -> (int * int) NodeMap.t NodeMap.t -> SetOfPath.t

  (**
  @requires un ensemble de chemin et un graph
  @ensures un ensemble de chemin correspondant 
  à tous les chemins possible dans le graphe
  @raises Rien
  *)
  val add_paths_to_set_while_possible :
    SetOfPath.t -> (int * int) NodeMap.t NodeMap.t -> SetOfPath.t

  (**
  @requires un noeud de départ , un noeud d'arrivé, un graph
  @ensures un ensemble de chemin correspondant à tous les chemins possible
  entre le noeud de départ et le noeud d'arrivé
  @raises Rien
  *)
  val all_path : node -> node -> (int * int) NodeMap.t NodeMap.t -> SetOfPath.t

  (**
  @requires un ensemble de chemin
  @ensures le plus petit chemin de l'ensemble
  @raises Rien
  *)
  val shortest_set : SetOfPath.t -> int

  (**
  @requires un noeud de départ , un noeud d'arrivé, un graph
  @ensures un ensemble de chemin correspondant à tous les chemins plus court
  @raises Rien
  *)
  val all_shortest_paths :
    node -> node -> (int * int) NodeMap.t NodeMap.t -> SetOfPath.t

  (****************************************************************************)
  (****************************************************************************)
  (***************************** Phase 2 **************************************)
  (****************************************************************************)
  (****************************************************************************)

  (****************************************************************************)
  (*****************************  dinic ***************************************)
  (****************************************************************************)

  (**
  @requires un tuple de 3 éléments
  @ensures le 3ème élément du tuple
  @raises Rien
  *)
  val get3rd : 'a * 'b * 'c -> 'c

  (**
  @requires un ensemble de chemin 
  @ensures le bottleneck de l'ensemble
  @raises Rien
  *)
  val get_bottleneck : (node * int * int) list -> int

  (**
  @requires un ensemble de chemin et un graph
  @ensures un booléen indiquant si il y a un flot bloquant
  @raises Rien
  *)
  val there_is_blocking_flow :
    (node * 'a * 'b) list -> (int * int) NodeMap.t NodeMap.t -> bool

  (**
  @requires 2 noeuds , une valeur min,max et un graph
  @ensures le graph avec la valeur min,max appliqué à l'arête
  @raises Rien
  *)
  val change_flow :
       node
    -> node
    -> 'a * 'b
    -> ('a * 'b) NodeMap.t NodeMap.t
    -> ('a * 'b) NodeMap.t NodeMap.t

  (**
  @requires un bottleneck, le min, le max 
  @ensures le min et le max modifié en fonction du bottleneck
  @raises Rien
  *)
  val add_until_saturated : int -> int -> int -> int * int

  val apply_bottleneck :
       (node * int * int) list
    -> (int * int) NodeMap.t NodeMap.t
    -> (int * int) NodeMap.t NodeMap.t

  (**
  @requires un graph
  @ensures une liste des noeuds, ou une arête part de celui-ci et est saturé
  @raises Rien
  *)
  val list_of_blacklisted_node : ('a * 'a) NodeMap.t NodeMap.t -> node list

  (**
  @requires  un noeud , un graph
  @ensures le flot maximal arrivant au noeud
  @raises rien
  *)
  val get_maximum_flow_from_node : node -> (int * 'b) NodeMap.t NodeMap.t -> int

  (**
  @requires un noeud de départ, un noeud d'arrivé, un graph
  @ensures dinic appliqué à un graph
  @raises Rien
  *)
  val dinic :
       node
    -> node
    -> (int * int) NodeMap.t NodeMap.t
    -> (int * int) NodeMap.t NodeMap.t

  (*********************** cleaning function **********************************)

  (* ces fonctions n'ont finalement pas été utilisé.
     Il n'est pas nécessaire de refaire le graph à chaque fois*)

  (**
  @requires un noeud de départ , un noeud d'arrivé, un graph
  @ensures un ensemble de noeud qui ne font pas partie des plus court chemin
  @raises Rien
  *)
  val blacklisted_node :
    node -> node -> (int * int) NodeMap.t NodeMap.t -> NodeSet.t

  (**
  @requires un noeud de départ , un noeud d'arrivé, un graph
  @ensures un graph sans les noeuds qui ne font pas partie des plus court chemin
  @raises Rien
  *)
  val clean_graph :
       node
    -> node
    -> (int * int) NodeMap.t NodeMap.t
    -> (int * int) NodeMap.t NodeMap.t

  (**
  @requires un noeud et un ensemble de chemin
  @ensures un ensemble de chemin sans le noeud
  @raises Rien
  *)
  val clean_set_from_node : node -> SetOfPath.t -> SetOfPath.t

  (**
  @requires un ensemble de chemin et une liste de noeud
  @ensures un ensemble de chemin sans les noeuds de la liste
  @raises Rien
  *)
  val clean_set : SetOfPath.t -> node list -> SetOfPath.t
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

  type node = X.t

  type graph = (int * int) NodeMap.t NodeMap.t

  module SetOfPath = Set.Make (struct
    type t = (node * int * int) list

    let compare = compare
  end)

  let empty = NodeMap.empty

  (***********  let ***********  SUCCS FUNCTION *******************************)

  let succs n g =
    (*si le noeud appartient au graph,
      on retourne la clé , sinon on retourne rien*)
    try NodeMap.find n g with Not_found -> NodeMap.empty

  (************************  BOOL FUNCTION ************************************)

  let is_empty g = NodeMap.is_empty g

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

  let mem_set_of_path n1 l =
    List.fold_left (fun acc (n, min, max) -> acc || n = n1) false l

  (**********************  FOLD FUNCTION ***********************************)

  (*
     le fold n'est fait que sur les clé, donc les noeuds
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
          successeur acc1 )
      g acc

  (***********************  ADDING FUNCTION ***********************************)

  (* ajoute un noeud au graphe, qui n'est relié à rien *)
  let add_lonely_node n g =
    if mem_node n g then
      (* si un noeud existe déjà, il n'est pas ajouté au graph *)
      g
    else
      (*sinon on l'ajoute, relié à rien*)
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
    remove_edge n2 n1 graph_unlink_n1_to_n2

  let remove_node n g =
    if mem_node n g then
      let graph_without_successor_to_n =
        (* pour le dictionnaire de successeurs, on applique remove,
           afin d'enlever la clé n ,
           et on ajoute cette nouvelle map à la clé , ce qui
           met donc à jour ses successeurs*)
        NodeMap.fold
          (fun noeud valeur acc ->
            NodeMap.add noeud (NodeMap.remove n valeur) acc )
          g NodeMap.empty
      in
      NodeMap.remove n graph_without_successor_to_n
    else
      g

  (********************  COUNTING FUNCTION *********************************)

  (* nombre d'arc qui pointe vers le noeud*)
  let number_of_incoming_edge n g =
    if mem_node n g then
      fold_succs
        (fun node _ acc ->
          if node = n then
            acc + 1
          else
            acc )
        g 0
    else
      failwith "number_of_incoming_edge : le noeud n'existe pas"

  (* nombre d'arc qui quitte le noeud, c'est donc le nombre de successeurs*)
  let number_of_outgoing_edge n g =
    if mem_node n g then
      let map_of_succs = succs n g in
      NodeMap.cardinal map_of_succs
    else
      failwith "number_of_outgoing_edge : le noeud n'existe pas"

  (******************** GETTER FUNCTION ****************************)
  let get_flow (n1, n2) g =
    if mem_edge n1 n2 g then
      let succs_of_n1 = succs n1 g in
      let min, max = NodeMap.find n2 succs_of_n1 in
      (min, max)
    else
      failwith "get_flow : l'arête n'existe pas"

  (********************  LIST TO GRAPH FUNCTION ****************************)

  (* crée les noeuds ainsi que le lien entre start et finish
     goal :
     [(a,1,2,b);(a,3,4,c)]
     a --(1,2)---> b
     |
     |----(3,4)----> c
  *)

  let list_to_graph l =
    List.fold_right
      (fun (start, min, max, finish) acc -> add_node start min max finish acc)
      l empty

  let list_to_graph_no_pond l =
    List.fold_right
      (fun (start, finish) acc -> add_node start 0 1 finish acc)
      l empty

  (****************************************************************************)
  (****************************************************************************)
  (***************************** Phase 1 **************************************)
  (****************************************************************************)
  (****************************************************************************)

  (** BUT : partir de a , trouver l'ensemble des plus court chemins

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
     ex ensemble : 
 {
  [(a,1);(b,1)]
  [(d,1)]
  [(e,1)]
 }
  *)

  (* fonction qui ajoute tous les chemins dans un ensemble de chemin *)
  (* uniquement si l'arête n'est pas pleine *)
  let add_paths_to_set ensInit g =
    (* on fold dans l'ensemble des chemins*)
    SetOfPath.fold
      (fun listOfPath acc1 ->
        (* on parcours chaque liste correspondant à un chemin*)
        (* on récupère le dernier noeud du chemin*)
        let n, min, max = List.hd listOfPath in
        (*on récupère ses successeurs*)
        let succs_of_n = succs n g in
        (*on fold sur tous les successeurs
           pour les ajouter à l'ensemble des chemins*)
        NodeMap.fold
          (* on ajoute le nouveau chemin à l'ensemble des chemin*)
            (fun nodeSuccessor (min, max) acc2 ->
            if min <> max then
              let newPath =
                if List.hd listOfPath = (nodeSuccessor, min, max) then
                  (* on vérifie si le noeud est déja la ,
                     permet d'évitez les boucles
                  *)
                  listOfPath
                else
                  (nodeSuccessor, min, max) :: listOfPath
              in
              SetOfPath.add newPath acc2
            else
              (* si arête saturé, on passe au prochain chemin*)
              acc2 )
          succs_of_n acc1 )
      ensInit ensInit

  (* fonction qui tant que les élément dans le SetOfPath ont des successeurs,
     appel add_paths_to_set *)
  (* cela permet de remplir l'ensemble de tous les chemins possibles*)
  let rec add_paths_to_set_while_possible ensInit g =
    (* on ajoute les chemins tant que c'est possible*)
    let newSetOfPath = add_paths_to_set ensInit g in
    (* si le nouveau set est différent du set de base, on rappel la fonction*)
    if not (SetOfPath.equal ensInit newSetOfPath) then
      add_paths_to_set_while_possible newSetOfPath g
    else
      newSetOfPath

  (* maintenant, il suffit de prendre un noeud de départ
     et d'appliquer la fonction pour avoir l'ensemble
     avec tous les chemins allant de start vers goal *)
  let all_path start goal g =
    (* on transforme le noeud en ensemble*)
    let startingSet = SetOfPath.singleton [(start, 0, 0)] in
    (* on applique la fonction, on a donc tous les chemins possible du graph*)
    let allSet = add_paths_to_set_while_possible startingSet g in
    (* il suffit de remove ceux qui ne commence pas par goal ,
       le plus récent est la tête de la liste il suffit de regarder
       la tête *)
    SetOfPath.filter
      (fun listOfPath ->
        let n, min, max = List.hd listOfPath in
        n = goal )
      allSet

  (* fonction qui trouve le plus petit chemin à partir d'un ensemble*)
  let shortest_set set =
    (*fold sur l'ensemble*)
    SetOfPath.fold
      (fun listOfPath acc ->
        (* on regarde s'il y a plus court*)
        if List.length listOfPath < acc then
          List.length listOfPath
        else
          acc )
      set
      (* on commence en prenant la taille du premier set*)
      (List.length (SetOfPath.choose set))

  (* fonction qui prend tous les chemins dans un ensemble,
     trouve le plus cours, et filtre afin de garder tout ceux égal
     au plus court*)
  let all_shortest_paths start goal g =
    try
      let allPath = all_path start goal g in
      let shortest = shortest_set allPath in
      SetOfPath.filter
        (fun listOfPath -> List.length listOfPath = shortest)
        allPath
    with Not_found -> SetOfPath.empty

  (****************************************************************************)
  (****************************************************************************)
  (***************************** Phase 2 **************************************)
  (****************************************************************************)
  (****************************************************************************)

  (****************************************************************************)
  (*****************************  dinic ***************************************)
  (****************************************************************************)

  (* but :

     Pour chaque chemin dans l'ensemble des chemins les plus courts
     - Parcourir de source à destination, en utilisant uniquement
       les arêtes valides ; si on atteint la destination,
       on met le poids de toutes les arêtes par lequel on est passé à jour,
       c'est à dire au flot bloquant
       (puis blacklist les noeuds empruntés saturé)
     - On s'arrête quand on ne peut plus atteindre la destination
       par des arêtes qui n'ont pas déja été utilisé
       (regarder si le noeud est dans la blacklist)
     - On recommence l'algorithme seulement sur les arêtes qui n'ont pas été
       saturé
  *)

  let get3rd (n1, n2, n3) = n3

  (* fonction qui prend un chemin et qui retourne le flot bottleneck *)
  let get_bottleneck l =
    List.fold_left
      (fun acc (n1, min, max) ->
        (* pour cela on regarde si on a commencé avec un flot = 0*)
        (* et on prendra toujours le plus petit intervalle max - min *)
        if acc = 0 then
          max - min
        else if max - min < acc then
          max - min
        else
          acc )
      (get3rd (List.hd l))
      l

  (* s'il y a un flot bloquant, on arrête, il faut donc pouvoir en répérer un *)

  (**
  @warning list_of_path est dans le bon sens  
  *)
  let there_is_blocking_flow list_of_path g =
    let rec aux l =
      match l with
      | [] | [_] ->
          false (* on a besoin de 2 noeud pour avoir le flot*)
      (* il faut regarder dans le graph car les informations
         des liste ne sont peut être plus à jour *)
      | (n1, min1, max1) :: (n2, min2, max2) :: t ->
          let min, max = get_flow (n1, n2) g in
          if min = max then
            true
          else
            aux ((n2, min2, max2) :: t)
    in
    aux list_of_path

  let change_flow n1 n2 (min, max) g =
    let succs_of_n1 = succs n1 g in
    (* on remplace *)
    let new_succs_n1 = NodeMap.add n2 (min, max) succs_of_n1 in
    NodeMap.add n1 new_succs_n1 g

  (* en appliquant le bottleneck à la liste à l'envers,
     donc de start à goal, on le parcourt également,
     si on sature une arête on la supprime de l'ensemble,
     on refait l'ensemble à partir de ça et on recommence *)

  (* on ne veut pas avoir 90 / 7 par ex, il faut donc ajouter en saturant *)
  let add_until_saturated bneck borneMin borneMax =
    let remain = borneMax - borneMin in
    if remain > 0 then
      if bneck >= remain then
        (borneMax, borneMax)
      else
        (borneMin + bneck, borneMax)
    else
      (borneMin, borneMax)

  (**
  @warning list_of_path est dans le bon sens
  *)
  let apply_bottleneck list_of_path g =
    (* on regarde si il y a un flot bloquant dans le chemin*)
    if there_is_blocking_flow list_of_path g then
      g
    else
      (* il n'y a aucun flot bloquant la ou on se situe*)
      let bneck = get_bottleneck list_of_path in
      (* on applique le bottleneck à toutes les arêtes *)
      let rec aux l graphAux =
        match l with
        | (n1, min1, max1) :: (n2, min2, max2) :: t ->
            let newMinMax = add_until_saturated bneck min2 max2 in
            (* on change la valeur du flow si l'arête n'est pas saturé*)
            let newG = change_flow n1 n2 newMinMax graphAux in
            (* on applique aux élements d'après *)
            aux ((n2, min2, max2) :: t) newG
        | [] | [_] ->
            graphAux
      in
      aux list_of_path g

  (* une itération est faite, il faut maintenant supprimer les arêtes *)

  (* on crée une liste ou n1 ---> x  est saturé, on stock n1 ,
     dès qu'il apparait dans un chemin on dégage le chemin*)
  let list_of_blacklisted_node g =
    NodeMap.fold
      (fun noeudStart succs acc ->
        NodeMap.fold
          (fun noeudEnd (min, max) acc1 ->
            if min = max then
              noeudStart :: acc1
            else
              acc1 )
          succs acc )
      g []

  let get_maximum_flow_from_node goal g =
    NodeMap.fold
      (fun noeudStart succs acc ->
        NodeMap.fold
          (fun noeudEnd (min, max) acc1 ->
            if noeudEnd = goal then
              acc1 + min
            else
              acc1 )
          succs acc )
      g 0

  let rec dinic start goal g =
    let shortest_path = all_shortest_paths start goal g in
    if shortest_path = SetOfPath.empty then
      g
    else
      let g =
        SetOfPath.fold
          (fun path acc -> apply_bottleneck (List.rev path) acc)
          shortest_path g
      in
      dinic start goal g

  (*********************** cleaning function **********************************)

  (*les niveaux se font uniquement à partir des chemins les plus courts
    vers le puits, à la fin on a un ensemble de tous les noeuds
    qui ne font pas partie des plus courts chemins*)

  let blacklisted_node start goal g =
    (* on créer un ensemble qui contient tous les noeuds du graph *)
    let set_of_all_node =
      fold_node (fun node acc -> NodeSet.add node acc) g NodeSet.empty
    in
    let set_shortest_path = all_shortest_paths start goal g in
    (* on crée un ensemble qui contient tous les noeuds du plus petit*)
    let set_of_node_shortest_path =
      SetOfPath.fold
        (fun listOfPath acc ->
          List.fold_right
            (fun (node, min, max) acc -> NodeSet.add node acc)
            listOfPath acc )
        set_shortest_path NodeSet.empty
    in
    NodeSet.diff set_of_all_node set_of_node_shortest_path

  let clean_graph start goal g =
    let blacklisted = blacklisted_node start goal g in
    NodeSet.fold (fun node acc -> remove_node node acc) blacklisted g

  let clean_set_from_node n ens =
    SetOfPath.filter (fun listOfPath -> not (mem_set_of_path n listOfPath)) ens

  let clean_set s l =
    List.fold_left (fun acc noeud -> clean_set_from_node noeud acc) s l
end

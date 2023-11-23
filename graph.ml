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

  type graph
  type node

  (** Le graph vide *)
  val empty : graph

  (**********************  BOOLEAN FUNCTION ***********************************)

  (**
  @requires Rien 
  @ensures True si graph vide, False sinon 
  @raises Rien 
  *)
  val is_empty : graph -> bool

  (**********************  FOLD FUNCTION ***********************************)

  (**
  @requires Rien
  @ensures un fold sur le graph
  @raises Rien
  *)
  val fold_node : (node -> 'a -> 'a) -> graph -> 'a -> 'a

  (**********************  SUCCS FUNCTION ***********************************)

  (**
  @requires le noeud node appartient au graph 
  @ensures un ensemble correspondant au successeur du noeud 
  passé en paramètre
  @raises le noeud dont on cherche le successeur n'appartient pas au graph 
  *)
  val succs : node -> graph -> 'a NodeMap.t

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
  @raises si n1 n'appartient pas au graph 
  *)
  val mem_edge : node -> node -> graph -> bool

  (**********************  ADDING FUNCTION ***********************************)

  (**
  @requires un noeud au graph, ce noeud n'est relié à rien 
  @ensures l'ajout d'un noeud au graph si le noeud existe, il n'est pas rajouté
  @raises Rien
  *)
  val add_lonely_node : node -> graph

  (*TODO REFAIRE EXCEPTION A PARTIR DE LA*)

  (**
  @brief Fonction qui prend 2 noeud existant et qui lie le noeud A 
  au noeud B avec la pondération n
  @requires les 2 noeuds existent 
  @ensures la création d'une arête entre les 2 noeuds
  @raises EmptyMap si les 2 noeuds n'existe pas
  *)
  val add_edge : node -> int -> node -> graph -> graph

  (**
  @brief Même fonction que pour add_edge mais pour les graphe non pondéré (toutes les pondérations sont à 1 )
  @requires les 2 noeuds existent 
  @ensures la création d'une arête entre les 2 noeuds
  @raises EmptyMap 
  *)
  val add_default_edge : node -> graph

  (**
  @brief Fonction qui prend un noeud et un entier, la fonction ajoute un successeur à ce noeud, de pondération n, elle crée donc un node et connecte les 2 
  @requires que le noeud existe dans le graph 
  @ensures, l'ajoute d'un noeud de pondération n , successeur du noeud
  donnée en paramètre 
  @raises EmptyMap si le noeud en paramètre n'existe pas 
  @example add_node (B) 2 (C) (G) (donne le graph ascii plus haut)
  B ----------- 2 ---------> C 
  *)
  val add_node : node -> int -> node -> graph -> graph

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
  @raises EmptyMap si les 2 noeuds n'existe pas
  *)
  val remove_edge : node -> node -> graph -> graph

  (**
  @requires les 2 nodeuds 
  @ensures que l'arête 1 -----> 2 ET 2 --------> 1
  @raises EmptyMap si les 2 noeuds n'existe pas
  *)
  val remove_edges : node -> node -> graph -> graph

  (**
  @requires le noeud à récupérer ainsi que le graph 
  @ensures que le noeud soit bien retirer du graph ainsi que les noeuds qui pointent vers lui
  @raises Rien 
  @brief, il faut utiliser un fold , il faut fold le remove edge sur tous
  les noeuds du graph 
  *)
  val remove_node : node -> graph -> graph

  (**********************  TRAVERSAL FUNCTION ********************************)

  (* prend un noeud et return la liste de toutes les itérations du bfs *)
  val bfs : node -> graph -> node list list
end

(************************************************************************)
(************************************************************************)
(************************************************************************)
(************************************************************************)
(**********************  IMPLEMENTATION  ********************************)
(************************************************************************)
(************************************************************************)
(************************************************************************)
(************************************************************************)

module Make (X : Map.OrderedType) = struct
  module NodeMap = Map.Make (X)

  type node = X.t
  type graph = int NodeMap.t NodeMap.t

  let empty = NodeMap.empty
  let is_empty g = NodeMap.is_empty g

  (**********************  FOLD FUNCTION ***********************************)

  let fold_node (f : node -> 'a -> 'a) (g : graph) (acc : 'a) =
    NodeMap.fold (fun currNode _ acc -> f currNode acc) g acc
  ;;

  (**********************  SUCCS FUNCTION ***********************************)

  let succs (n : node) (g : graph) =
    (*si le noeud appartient au graph,
      on retourne la clé , sinon on retourne rien*)
    try NodeMap.find n g with
    | Not_found -> failwith "succs : le noeud n'apppartient pas au graph"
  ;;

  (********************** MEM FUNCTION ***********************************)
  let mem_node (n : node) (g : graph) = NodeMap.mem n g

  let mem_edge (n1 : node) (n2 : node) (g : graph) =
    (*si n1 n'est pas dans le graph , exception*)
    if not (mem_node n1 g) then
      failwith "mem_edge : le noeud n1 n'appartient pas au graph"
      (*sinon on cherche parmi ses successeurs si n2 existe *)
    else (
      let succs_of_n1 = succs n1 g in
      NodeMap.mem n2 succs_of_n1)
  ;;

  (**********************  ADDING FUNCTION ***********************************)

  let add_lonely_node (n : node) (g : graph) =
    (* si un noeud existe déjà, il n'est pas ajouté au graph *)
    if mem_node n g then
      g
      (*sinon on l'ajoute*)
    else
      NodeMap.add n NodeMap.empty g
  ;;

  (* fais : n1 ----- (pond) ----> n2 ; si n1 et n2 existe dans le graph *)
  let add_edge (n1 : node) (pond : int) (n2 : node) (g : graph) =
    if mem_node n1 g && mem_node n2 g then (
      let updated_succs = NodeMap.add n2 pond (succs n1 g) in
      (*the previous binding will be overwritten *)
      NodeMap.add n1 updated_succs g)
    else
      raise EmptyMap
  ;;

  let add_default_edge (n1 : node) (n2 : node) (g : graph) = add_edge n1 1 n2 g

  let add_node
    (base_node : node)
    (ponderation : int)
    (node_to_add : node)
    (g : graph)
    =
    (*si le noeud de base existe*)
    if mem_node base_node g then (
      (*on crée le nouveau noeud*)
      let newGraph = add_lonely_node node_to_add g in
      (* on lie les 2 noeud *)
      add_edge base_node ponderation node_to_add newGraph)
    else
      raise EmptyMap
  ;;

  let add_default_node (n1 : node) (n2 : node) (g : graph) = add_node n1 1 n2 g

  (**********************  REMOVE FUNCTION ***********************************)

  let remove_edge (n1 : node) (n2 : node) (g : graph) =
    if mem_node n1 g && mem_node n2 g then (
      (*on supprime l'arête n1 -----> n2 *)
      let successor_of_n1 = succs n1 g in
      let updated_successor_of_n1 = NodeMap.remove n2 successor_of_n1 in
      NodeMap.add n1 updated_successor_of_n1 g)
    else
      failwith "remove_edge : les 2 noeuds n'existent pas"
  ;;

  let remove_edges (n1 : node) (n2 : node) (g : graph) =
    let graph_unlink_n1_to_n2 = remove_edge n1 n2 g in
    let graph_unlink_n2_to_n1 = remove_edge n2 n1 graph_unlink_n1_to_n2 in
    graph_unlink_n2_to_n1
  ;;
end

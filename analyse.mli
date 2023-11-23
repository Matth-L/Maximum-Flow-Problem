val phase1
  :  unit (* nom du fichier à lire passé en argument *)
  -> string
     * (* source *)
       string
     * (* puit *)
     (string * string) list (* couloirs *)

val phase2
  :  unit (* nom du fichier à lire passé en argument *)
  -> string
     * (* source *)
       string
     * (* puit *)
     (string * string * int) list (* couloirs avec capacité *)

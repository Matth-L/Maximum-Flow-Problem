OCAMLFLAGS = ocamlc -g
OCAMLDEBUG = ocamlrun -b -t cprogs
TARGET = test phase1 phase2

.PHONY = all clean tests

test : graph.cmo testGraph.cmo
	$(OCAMLFLAGS)  graph.cmo testGraph.cmo -o test

phase1 : graph.cmo analyse.cmi analyse.cmo main.cmo
	$(OCAMLFLAGS) graph.cmo analyse.cmo main.cmo -o phase1 

main.cmo : main.ml
	$(OCAMLFLAGS) -c main.ml

analyse.cmo : analyse.ml
	$(OCAMLFLAGS) -c analyse.ml

analyse.cmi : analyse.mli
	$(OCAMLFLAGS) -c analyse.mli

graph.cmo : graph.ml
	$(OCAMLFLAGS) -c graph.ml

testGraph.cmo : testGraph.ml
	$(OCAMLFLAGS) -c testGraph.ml

clean :
	rm -vf *.cmo *.cmi $(TARGET)

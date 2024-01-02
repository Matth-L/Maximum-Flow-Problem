OCAMLFLAGS = ocamlc -g
OCAMLDEBUG = ocamlrun -b -t cprogs
TARGET = test phase1 phase2 phase1.txt phase2.txt

.PHONY = all clean tests

test :  graph.cmo testGraph.cmo
	$(OCAMLFLAGS)  graph.cmo testGraph.cmo -o test
	./test

phase1 : graph.cmo analyse.cmi analyse.cmo phase1.cmo
	$(OCAMLFLAGS) graph.cmo analyse.cmo phase1.cmo -o phase1 

phase1.cmo : phase1.ml
	$(OCAMLFLAGS) -c phase1.ml

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

OCAMLFLAGS = ocamlc -g
OCAMLDEBUG = ocamlrun -b -t cprogs
TARGET = test

.PHONY = all clean test phase1 phase2

phase1 : graph.cmo analyse.cmo main.cmo
	$(OCAMLFLAGS) $< -o $(TARGET) 

graph.cmo : graph.ml 
	$(OCAMLFLAGS) -c $<

test : graph.cmo test.cmo
	$(OCAMLFLAGS) test.cmo -o $(TARGET) 

%.cmo : %.ml
	$(OCAMLFLAGS) -c $<

%.cmi : %.mli
	$(OCAMLFLAGS) -c $<

clean : 
	rm -f *.cmo *.cmi $(TARGET) *.out *.diff
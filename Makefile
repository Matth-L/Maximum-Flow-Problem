OCAMLFLAGS = ocamlc -g
OCAMLDEBUG = ocamlrun -b -t cprogs
TARGET = test phase1 phase2 
TOCLEAN = *.cmo *.cmi $(TARGET) phase1.txt phase2.txt

.PHONY = all clean tests

all : $(TARGET)

test :  graph.cmo testGraph.cmo
	$(OCAMLFLAGS)  graph.cmo testGraph.cmo -o test

phase1 : graph.cmo analyse.cmi analyse.cmo phase1.cmo
	$(OCAMLFLAGS) graph.cmo analyse.cmo phase1.cmo -o $@ 

phase2 : graph.cmo analyse.cmi analyse.cmo phase2.cmo
	$(OCAMLFLAGS)  graph.cmo analyse.cmo phase2.cmo -o $@

%.cmo : %.ml
	$(OCAMLFLAGS) -c $<

%.cmi : %.mli
	$(OCAMLFLAGS) -c $<

clean :
	rm -vf $(TOCLEAN)
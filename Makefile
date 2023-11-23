OCAMLFLAGS = ocamlc
TARGET = test

.PHONY = all clean tests

$(TARGET) : graph.cmo testGraph.cmo
	$(OCAMLFLAGS)  graph.cmo testGraph.cmo -o $@
	./test

%.cmo : %.ml
	$(OCAMLFLAGS) -c $< -o $@

clean : 
	rm -fv *~ *.cm[io] $(TARGET)
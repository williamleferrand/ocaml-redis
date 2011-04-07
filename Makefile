all: byte native

byte:
	ocamlbuild src/redis.cmo

native:
	ocamlbuild src/redis.cmx

clean:
	ocamlbuild -clean
	find . |grep '~' |xargs rm -rf 

install:
	ocamlfind install redis META _build/src/redis.cm*

remove:
	ocamlfind remove redis
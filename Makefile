
OPTS?= --profile=release
all:
	dune build $(OPTS) @install

install-opam-deps:
	opam install jemalloc yojson

clean:
	dune clean

WATCH?= @install @runtest
watch:
	dune build $(OPTS) $(WATCH) -w

.PHONY: clean all watch install-opam-deps


OPTS?= --profile=release
all:
	dune build $(OPTS) @install

clean:
	dune clean

WATCH?= @install @runtest
watch:
	dune build $(OPTS) $(WATCH) -w

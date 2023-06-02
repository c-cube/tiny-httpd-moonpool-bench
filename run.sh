#!/bin/sh
DUNE_OPTS="--release --display=quiet"
exec dune exec $DUNE_OPTS examples/t1.exe -- $@

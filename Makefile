all: build

build:
	dune build

install:
	dune install

test: build
	dune exec bin/main.exe test/test.md test_output.html

clean:
	dune clean
	rm -f test_output.html

.PHONY: all build install test clean

#!/bin/bash
set -x

whoami

opam init -y -a
opam install depext
opam depext conf-m4.1
opam install -y merlin

eval `opam config env`
#!/bin/sh
set -ex

docker build . -t ocrd_trocr:latest -f Dockerfile-ocrd_trocr

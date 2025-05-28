#!/bin/bash

set -ue

docker build -t "emaniacs/$1:latest" -f "$1/Dockerfile" $1

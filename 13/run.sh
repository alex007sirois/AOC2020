#!/bin/bash

set -e

docker build -q -t solve .
docker run --rm --name solve solve

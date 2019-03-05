#!/bin/bash
set -eux

names=( fly credhub )
for name in "${names[@]}"
do
  chmod +x /usr/bin/$name
  sync # docker bug requires this
  $name --version
done

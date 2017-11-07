#!/bin/bash

for i in {1..5}; do
    echo "bashscript output: for loop line $i"
    sleep .5
done
echo $(pwd)
exit

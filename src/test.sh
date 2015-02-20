#!/bin/bash
args=$@
if [ $# -ne 0 ]; then
    echo start
else
    echo dontstart
fi

echo Number of arguments: $#
echo First argument: ${args[1]}




#!/bin/bash

set -e

if [ -d ".ssh" ]; then
    rm -rf .ssh
fi

mkdir -p .ssh
ssh-keygen -t rsa -b 4096 -f .ssh/jmeter -q -N ""

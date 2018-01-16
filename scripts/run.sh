#!/bin/bash

set -e

MASTER=$(terraform output master_address)
USER=$(terraform output run_user)

echo ssh -i .ssh/jmeter -o IdentitiesOnly=yes -oStrictHostKeyChecking=no $USER@$MASTER

if [ -z "$1" -o ! -f "$1" ]; then
    echo "Please provide a test file"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Please provide a result destination file"
    exit 2
fi

scp -i .ssh/jmeter -o IdentitiesOnly=yes -oStrictHostKeyChecking=no $1 ${USER}@$MASTER:test.jmx
ssh -i .ssh/jmeter -o IdentitiesOnly=yes -oStrictHostKeyChecking=no ${USER}@$MASTER rm -vf results.jtl
ssh -i .ssh/jmeter -o IdentitiesOnly=yes -oStrictHostKeyChecking=no ${USER}@$MASTER /opt/jmeter/bin/jmeter -n -r -t test.jmx -l results.jtl
scp -i .ssh/jmeter -o IdentitiesOnly=yes -oStrictHostKeyChecking=no ${USER}@$MASTER:results.jtl $2

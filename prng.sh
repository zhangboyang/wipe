#!/bin/bash

# generate stream of infinite random bytes to stdout
# use openssl's aes-256-ctr encryption as prng

# generate key and iv
KEY="$(cat /dev/urandom | tr -d -c 0-9A-F | head -c 64)"
IV="$(cat /dev/urandom | tr -d -c 0-9A-F | head -c 32)"
echo "KEY=$KEY" 1>&2
echo "IV=$IV" 1>&2

# invoke openssl
# UNSAFE: key and iv passed by cmdline, other user can use ps(1) to steal it
openssl enc --aes-256-ctr -K "$KEY" -iv "$IV" -in /dev/zero

# exit with code 0
exit 0

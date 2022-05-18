#!/bin/bash

# do one round of wipe
# return non-zero if error occurred

# write random bytes first, then write zeros
if (echo "$1: FILL RANDOM ..." 1>&2; ./prng.sh | ./wipe.sh "$1") && \
   (echo "$1: FILL ZERO ..." 1>&2; ./wipe.sh "$1" < /dev/zero); then
  echo "$1: ROUND OK!" 1>&2
  exit 0
else
  echo "$1: BAD ROUND!" 1>&2
  exit 1
fi

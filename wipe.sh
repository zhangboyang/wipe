#!/bin/bash

# write stdin to block device
# then read back and check consistency
# return non-zero if error occurred

# check args
BDEV="$1"
if [ -z "$BDEV" ]; then
  echo "no BDEV" 1>&2
  exit 1
fi

# get block device size
SZ="$(blockdev --getsize64 "$BDEV")"
echo "SZ=$SZ" 1>&2
if [ -z "$SZ" ]; then
  echo "bad SZ" 1>&2
  exit 1
fi

# block size
#BS=1048576
BS=4096
echo "BS=$BS" 1>&2
MOD="$(($SZ%$BS))"
echo "MOD=$MOD" 1>&2
if [ "$MOD" -ne 0 ]; then
  echo "bad BS (SZ % BS != 0)" 1>&2
  exit 1
fi
COUNT="$(($SZ/$BS))"
echo "COUNT=$COUNT" 1>&2

# create temp files for checksums
# FIXME: b2sum is performance bottleneck
SUM1="$(mktemp)"
SUM2="$(mktemp)"

# write
echo "WRITE..." 1>&2
#dd iflag=fullblock bs="$BS" count="$COUNT" status=none | tee >(b2sum > "$SUM1") | dd iflag=fullblock oflag=direct of="$BDEV" bs="$BS" count="$COUNT" status=progress
dd iflag=fullblock bs="$BS" count="$COUNT" status=none | tee >(b2sum > "$SUM1") | dd iflag=fullblock of="$BDEV" bs="$BS" count="$COUNT" status=progress
cat "$SUM1" 1>&2

# sync
sync
sync

# drop cache
# FIXME: device may have their own cache
echo 3 > /proc/sys/vm/drop_caches

# read
echo "READ..." 1>&2
dd iflag=fullblock if="$BDEV" bs="$BS" count="$COUNT" status=progress | b2sum > "$SUM2"
cat "$SUM2" 1>&2

# verify checksums
if diff "$SUM1" "$SUM2" 1>&2; then
  echo "$BDEV: VERIFY OK!" 1>&2
  rm -f "$SUM1" "$SUM2"
  exit 0
else
  echo "$BDEV: VERIFY FAILED!" 1>&2
  rm -f "$SUM1" "$SUM2"
  exit 1
fi

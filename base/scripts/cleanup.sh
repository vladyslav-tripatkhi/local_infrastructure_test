#!/usr/bin/env bash

echo "==> Removing apt-cache"
apt-get clean

echo "==> Zeroing out the drive"
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

echo "==> cleaning out bash history"
cat /dev/null > ~/.bash_history && history -c && exit
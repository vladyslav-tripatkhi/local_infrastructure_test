#!/usr/bin/env bash

echo "==> Update and upgrade apt cache"
apt-get -y update
apt-get -y upgrade

echo "==> Install python-pip and other necessary packages"
apt-get install -y --no-install-recommends python-setuptools python-pip htop sysstat

echo "==> Upgrade pip to the latest stable version"
pip install --upgrade pip
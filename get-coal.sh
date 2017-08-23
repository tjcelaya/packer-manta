#!/bin/sh

mkdir -p tmp
cd tmp
[ -e coal-latest.tgz ] || curl -C - -O https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/coal-latest.tgz
tar -zxvf coal-latest.tgz -C ./

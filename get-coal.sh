#!/bin/sh

[ -e coal-latest.tgz ] || curl -C - -O https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/coal-latest.tgz
mkdir -p vmx
tar -zxvf coal-latest.tgz -C ./vmx

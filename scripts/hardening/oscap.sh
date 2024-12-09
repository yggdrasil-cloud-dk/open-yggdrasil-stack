#!/bin/bash

set -x

apt install -y libopenscap8 bzip2

cd /tmp 
wget https://security-metadata.canonical.com/oval/com.ubuntu.$(lsb_release -cs).usn.oval.xml.bz2
bzip2 -d com.ubuntu.jammy.usn.oval.xml.bz2

oscap oval eval --report oval-jammy.html com.ubuntu.jammy.usn.oval.xml



#!/bin/bash

dir=$(dirname "$0")

find $dir -iname "*.rules" | xargs -I % cp % workspace/etc/kolla/config/prometheus/

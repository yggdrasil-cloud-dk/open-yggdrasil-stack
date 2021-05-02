#!/bin/bash

cd workspace
source kolla-venv/bin/activate

TRANSFORM_INVALID_GROUP_CHARS=never ansible all -m ping

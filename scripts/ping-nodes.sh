#!/bin/bash

cd workspace
source kolla-venv/bin/activate

ansible all -m ping

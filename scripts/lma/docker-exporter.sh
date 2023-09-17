#!/bin/bash

docker run --name docker_exporter --detach --restart always --volume "/var/run/docker.sock":"/var/run/docker.sock" --publish 9417:9417 prometheusnet/docker_exporter

# TODO:
# add scrape target as shown here: https://github.com/prometheus-net/docker_exporter

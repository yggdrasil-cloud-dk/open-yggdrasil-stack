mkdir -p /tmp/custom_metrics
docker run -it --name custom_exporter -d --network host -v /tmp/custom_metrics:/tmp/custom_metrics custom_exporter

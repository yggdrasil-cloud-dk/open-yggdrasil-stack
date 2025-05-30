#!/bin/bash

openstack coe cluster list -f value -c name | xargs -r openstack coe cluster delete 
while openstack coe cluster list -f value -c name | grep [a-zA-Z0-9]; do sleep 5; done
openstack coe cluster template list -f value -c name | xargs -r openstack coe cluster template delete

openstack share list -f value -c Name | xargs -r openstack share delete

openstack loadbalancer list -f value -c name | xargs -r openstack loadbalancer delete --cascade

openstack database instance list -f value -c Name | xargs -r openstack database instance delete
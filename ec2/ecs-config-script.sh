#!/bin/sh

export AWS_DEFAULT_REGION=us-east-1
eipid=eipalloc-5221703e
instanceid=$(wget -q -O - http://instance-data/latest/meta-data/instance-id)
aws ec2 associate-address --instance-id $instanceid --allocation-id $eipid

sleep 5

yum -y update
yum -y install ecs-init tmux

mkdir -p /etc/ecs
echo ECS_CLUSTER=default >> /etc/ecs/ecs.config
chkconfig --level 345 docker on
service docker start
start ecs
usermod -a -G docker ec2-user

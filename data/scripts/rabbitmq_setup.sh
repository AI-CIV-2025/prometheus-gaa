#!/bin/bash
#TASK Build a distributed task queue system with RabbitMQ
# Create a directory for RabbitMQ configuration
mkdir -p ./data/rabbitmq

# Define RabbitMQ configuration file
cat << EOF > ./data/rabbitmq/rabbitmq.conf
# RabbitMQ Configuration
# Define the default user and password (CHANGE THESE IN PRODUCTION!)
default_user = guest
default_pass = guest

# Enable management plugin
management.load_definitions = true

# Set the default vhost
default_vhost = /

# Set the default permissions for the default vhost
default_permissions.configure = .*
default_permissions.write = .*
default_permissions.read = .*

# Set the loopback users (users that can only connect from localhost)
loopback_users = guest

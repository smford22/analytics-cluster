#
# Cookbook Name:: analytics-cluster
# Attributes:: default
#
# Author:: Salim Afiune (<afiune@chef.io>)
#
# Copyright 2015, Chef Software, Inc.
#
# All rights reserved - Do Not Redistribute
#

#
# General AWS Attributes
#
# In addition to this set of attributes you MUST have a ~/.aws/config file like this:
# => $ vi ~/.aws/config
# => [default]
# => region = us-east-1
# => aws_access_key_id = YOUR_ACCESS_KEY_ID
# => aws_secret_access_key = YOUR_SECRET_KEY
default['analytics-cluster']['aws']['key_name']                = ENV['USER']
default['analytics-cluster']['aws']['ssh_username']            = nil
default['analytics-cluster']['aws']['security_group_ids']      = nil
default['analytics-cluster']['aws']['image_id']                = nil
default['analytics-cluster']['aws']['subnet_id']               = nil
default['analytics-cluster']['aws']['use_private_ip_for_ssh']  = false

# => The Cluste Name which will be use to define all default hostnames
default['analytics-cluster']['id'] = nil

# Specific attributes
default['analytics-cluster']['analytics']['version'] = 'latest'

# => Chef Server
default['analytics-cluster']['chef-server']['hostname']     = nil
default['analytics-cluster']['chef-server']['organization'] = 'my_enterprise'
default['analytics-cluster']['chef-server']['flavor']       = 't2.medium'

# => Analytics Server (Not Required)
#
# In order to provision an Analytics Server you have to first provision the entire
# `analytics-cluster::setup` after that, you are ready to run `analytics-cluster::setup_analytics`
# that will activate analytics.
default['analytics-cluster']['analytics']['hostname']  = nil
default['analytics-cluster']['analytics']['fqdn']      = nil
default['analytics-cluster']['analytics']['flavor']    = 't2.medium'

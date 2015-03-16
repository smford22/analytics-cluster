#
# Cookbook Name:: analytics-cluster
# Recipe:: destory_all
#
# Author:: Salim Afiune (<afiune@chef.io>)
#
# Copyright 2015, Chef Software, Inc.
#
# All rights reserved - Do Not Redistribute
#

# If we want to destroy everything. Let's do it! But in order.
# => Analytics Server
include_recipe "analytics-cluster::destroy_analytics"

# Then: We will destroy the chef-server that its being manage locally
include_recipe "analytics-cluster::destroy_chef_server"

# Finally: All the keys & creds used on the currect analytics-cluster
include_recipe "analytics-cluster::destroy_keys"

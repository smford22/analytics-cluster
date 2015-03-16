#
# Cookbook Name:: analytics-cluster
# Recipe:: destroy_analytics
#
# Author:: Salim Afiune (<afiune@chef.io>)
#
# Copyright 2015, Chef Software, Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'analytics-cluster::_aws_settings'

# If Analytics is enabled
if is_analytics_enabled?
  begin
    # Setting the new Chef Server we just created
    with_chef_server chef_server_url,
      client_name: 'chefadmin',
      signing_key_filename: "#{cluster_data_dir}/chefadmin.pem"

    # Destroy Analytics Server
    machine analytics_server_hostname do
      action :destroy
    end

    # Delete the lock file
    File.delete(analytics_lock_file)
  rescue Exception => e
    Chef::Log.warn("We can't proceed to destroy the Analytics Server.")
    Chef::Log.warn("We couldn't get the chef-server Public IP: #{e.message}")
  end
else
  Chef::Log.warn("You must provision an Analytics Server before be able to")
  Chef::Log.warn("destroy it. READ => analytics-cluster/setup_analytics.rb")
end

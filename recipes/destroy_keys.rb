#
# Cookbook Name:: analytics-cluster
# Recipe:: destroy_keys
#
# Author:: Salim Afiune (<afiune@chef.io>)
#
# Copyright 2015, Chef Software, Inc.
#
# All rights reserved - Do Not Redistribute
#

%W(
   encrypted_data_bag_secret
   validator.pem
   chefadmin.pem
   #{node['analytics-cluster']['analytics']['enterprise']}.creds
).each do |file|
  file File.join(cluster_data_dir, file) do
    action :delete
  end
end

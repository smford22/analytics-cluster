
# Recipe:: _helper
#
# Author:: Salim Afiune (<afiune@chef.io>)
#
# Copyright 2015, Chef Software, Inc.
#
# All rights reserved - Do Not Redistribute
#

require 'openssl'
require 'net/ssh'
require 'fileutils'
require 'securerandom'

module AnalyticsCluster
  module Helper
    def current_dir
      Chef::Config.chef_repo_path
    end

    def cluster_data_dir
      File.join(current_dir, '.chef', 'analytics-cluster-data')
    end

    # We will return the right IP to use depending wheter we need to
    # use the Private IP or the Public IP
    def get_aws_ip(n)
      if node['analytics-cluster']['aws']['use_private_ip_for_ssh']
        n['ec2']['local_ipv4']
      else
        n['ec2']['public_ipv4']
      end
    end

    # If a cluster ID was not provided (via the attribute) we'll generate
    # a unique cluster ID and immediately save it in case the CCR fails.
    def analytics_cluster_id
      unless node['analytics-cluster']['id']
        node.set['analytics-cluster']['id'] = "test-#{SecureRandom.hex(3)}"
        node.save
      end

      node['analytics-cluster']['id']
    end

    def chef_server_hostname
      unless node['analytics-cluster']['chef-server']['hostname']
        node.set['analytics-cluster']['chef-server']['hostname'] = "chef-server-#{analytics_cluster_id}"
      end

      node['analytics-cluster']['chef-server']['hostname']
    end

    def analytics_server_hostname
      unless node['analytics-cluster']['analytics']['hostname']
        node.set['analytics-cluster']['analytics']['hostname'] = "analytics-server-#{analytics_cluster_id}"
      end

      node['analytics-cluster']['analytics']['hostname']
    end

    # Generate or load an existing RSA keypair
    def builder_keypair
      if File.exists?("#{cluster_data_dir}/builder_key")
        OpenSSL::PKey::RSA.new(File.read("#{cluster_data_dir}/builder_key"))
      else
        OpenSSL::PKey::RSA.generate(2048)
      end
    end

    def builder_private_key
      builder_keypair.to_pem.to_s
    end

    def builder_public_key
      "#{builder_keypair.ssh_type} #{[builder_keypair.to_blob].pack('m0')}"
    end


    # Generate or load an existing encrypted data bag secret
    def encrypted_data_bag_secret
      if File.exists?("#{cluster_data_dir}/encrypted_data_bag_secret")
        File.read("#{cluster_data_dir}/encrypted_data_bag_secret")
      else
        # Ruby's `SecureRandom` module uses OpenSSL under the covers
        SecureRandom.base64(512)
      end
    end

    def chef_server_ip
      @@chef_server_ip ||= begin
        chef_server_node = Chef::Node.load(chef_server_hostname)
        chef_server_ip   = get_aws_ip(chef_server_node)
        Chef::Log.info("Your Chef Server Public/Private IP is => #{chef_server_ip}")
        chef_server_ip
      end
    end

    def analytics_lock_file
      "#{cluster_data_dir}/analytics"
    end

    def analytics_server_node
      @@analytics_server_node ||= begin
        Chef::REST.new(
          chef_server_config[:chef_server_url],
          chef_server_config[:options][:client_name],
          chef_server_config[:options][:signing_key_filename]
        ).get_rest("nodes/#{analytics_server_hostname}")
      end
    end

    def analytics_server_ip
      @@analytics_server_ip ||= begin
        analytics_server_ip   = get_aws_ip(analytics_server_node)
        Chef::Log.info("Your Analytics Server Public/Private IP is => #{analytics_server_ip}")
        analytics_server_ip
      end
    end

    def chef_server_url
      "https://#{chef_server_ip}/organizations/#{node['analytics-cluster']['chef-server']['organization']}"
    end

    def activate_analytics
      FileUtils.touch(analytics_lock_file)
    end

    def is_analytics_enabled?
      File.exist?(analytics_lock_file)
    end

    def analytics_server_attributes
      return {} unless is_analytics_enabled?
      {
        'analytics' => {
          'fqdn' => analytics_server_ip
        }
      }
    end

    def chef_server_attributes
      {
        'chef-server-12' => {
          'analytics' => { 'organization' => node['analytics-cluster']['chef-server']['organization'] },
          'api_fqdn' => chef_server_ip,
          'store_keys_databag' => false
        }.merge(analytics_server_attributes)
      }
    end

    def chef_server_config
      {
        chef_server_url: chef_server_url,
        options: {
          client_name: 'chefadmin',
          signing_key_filename: "#{cluster_data_dir}/chefadmin.pem"
        }
      }
    end
  end
end

Chef::Recipe.send(:include, AnalyticsCluster::Helper)
Chef::Resource.send(:include, AnalyticsCluster::Helper)

# This is the minimum config that is needed to let
# the provisioning cookbook `analytics-cluster` to work
current_dir       = File.dirname(__FILE__)
chef_repo_path    "#{current_dir}/.."
node_name         'chefadmin'
file_cache_path   File.join(current_dir, 'local-mode-cache', 'cache')
# Berkshelf no longer depedends on Chef so we avoid using the
# analytics_knife when running under a `berks` command.
if defined? ::Chef::Config
  analytics_knife    = File.join(current_dir, 'analytics-cluster-data', 'knife.rb')
  Chef::Config.from_file(analytics_knife) if File.exist?(analytics_knife)
end
cookbook_path "#{current_dir}/../cookbooks"

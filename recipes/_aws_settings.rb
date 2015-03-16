require 'chef/provisioning/aws_driver'

with_driver 'aws'

with_machine_options(
  bootstrap_options: {
    instance_type: node['analytics-cluster']['aws']['flavor'],
    key_name: node['analytics-cluster']['aws']['key_name'],
    security_group_ids: node['analytics-cluster']['aws']['security_group_ids']
  },
  ssh_username: node['analytics-cluster']['aws']['ssh_username'],
  image_id:     node['analytics-cluster']['aws']['image_id']
)

add_machine_options bootstrap_options: { subnet_id: node['analytics-cluster']['aws']['subnet_id'] } if node['analytics-cluster']['aws']['subnet_id']
add_machine_options use_private_ip_for_ssh: node['analytics-cluster']['aws']['use_private_ip_for_ssh'] if node['analytics-cluster']['aws']['use_private_ip_for_ssh']

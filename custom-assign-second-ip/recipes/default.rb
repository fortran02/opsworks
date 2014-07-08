
require "json"

ENV['AWS_CONFIG_FILE'] = "/root/.aws/config"
#template "#{ENV['AWS_CONFIG_FILE']}" do
#  source "config.erb"
#  mode "0600"
#  variables(
#    :ec2region  => node["second-ip"][:ec2region],
#    :ec2key     => node["second-ip"][:ec2key],
#    :ec2secret  => node["second-ip"][:ec2secret]
#  )
#end

service "network" do
  service_name "network"
  action :nothing
end

subnet_id = node[:opsworks][:instance][:subnet_id]
Chef::Log.info("SUBNET ID: " + subnet_id)
private_ip = node[:opsworks][:instance][:private_ip]
Chef::Log.info("Private IP: " + private_ip)
interfaces = `aws ec2 describe-network-interfaces \
              --filters Name=private-ip-address,Values=#{private_ip}`
parsed = JSON.parse(interfaces)
eni_id = parsed["NetworkInterfaces"][0]["NetworkInterfaceId"]
Chef::Log.info("ENI ID: " + eni_id)

new_private_ip = node["second-ip"][subnet_id]

execute "second_ip_add" do
  command "aws ec2 assign-private-ip-addresses \
    --network-interface-id #{eni_id} \
    --private-ip-addresses #{new_private_ip} \
    --allow-reassignment
  "
  notifies :restart, "service[network]", :delayed
end


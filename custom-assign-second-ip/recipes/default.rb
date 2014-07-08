include_recipe "custom-aws-cli-creds::default"

require "json"
require "open-uri"

ENV['AWS_CONFIG_FILE'] = ::File.join(node['custom-aws-cli-creds']['config-dir'], "aws_cli_config")
subnet_id = node[:opsworks][:instance][:subnet_id]
secondary_private_ip = node["custom-assign-second-ip"][subnet_id]

ruby_block "get instance aws info" do
  block do
    Chef::Log.info("SUBNET ID: " + subnet_id)
    private_ip = node[:opsworks][:instance][:private_ip]
    Chef::Log.info("Private IP: " + private_ip)
    interfaces = `aws ec2 describe-network-interfaces \
              --filters Name=private-ip-address,Values=#{private_ip}`
    parsed = JSON.parse(interfaces)
    eni_id = parsed["NetworkInterfaces"][0]["NetworkInterfaceId"]
    Chef::Log.info("ENI ID: " + eni_id)
    Chef::Log.info("Secondary IP: #{secondary_private_ip}")
    assign = `aws ec2 assign-private-ip-addresses \
            --network-interface-id #{eni_id} \
            --private-ip-addresses #{secondary_private_ip} \
            --allow-reassignment`
    Chef::Log.info("IP assignment output:" + assign)
  end
end

service "network" do
  service_name "network"
  action :restart
end

ruby_block "verify secondary IP" do
  block do
    eth0_mac = `/sbin/ifconfig eth0 | awk '/HWaddr/ {print $5}'`.strip.downcase
    Chef::Log.info("eth0 MAC: #{eth0_mac}")
    check_url = "http://169.254.169.254/latest/meta-data/network/interfaces/macs/#{eth0_mac}/local-ipv4s"
    attached_ips = open(check_url).read
    raise "Cannot find secondary IP!" unless attached_ips.split("\n").include?(secondary_private_ip)
    Chef::Log.info("Secondary IP #{secondary_private_ip} was assigned.")
  end
end


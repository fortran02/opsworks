module HelperFunctions
  require "json"
  require "open-uri"

  def secondary_ip_exists()
    @subnet_id = node[:opsworks][:instance][:subnet_id]
    @secondary_private_ip = node["custom-assign-second-ip"][@subnet_id]
    Chef::Log.info("Checking for secondary IP " + @secondary_private_ip)
    eth0_mac = `/sbin/ifconfig eth0 | awk '/HWaddr/ {print $5}'`.strip.downcase
    Chef::Log.info("eth0 MAC: #{eth0_mac}")
    check_url = "http://169.254.169.254/latest/meta-data/network/interfaces/macs/#{eth0_mac}/local-ipv4s"
    attached_ips = open(check_url).read
    attached_ips.split("\n").include?(@secondary_private_ip)
  end

  def get_eni_id()
    private_ip = node[:opsworks][:instance][:private_ip]
    Chef::Log.info("Getting ENI_ID for Private IP: " + private_ip)
    interfaces = `aws ec2 describe-network-interfaces \
              --filters Name=private-ip-address,Values=#{private_ip}`
    parsed = JSON.parse(interfaces)
    eni_id = parsed["NetworkInterfaces"][0]["NetworkInterfaceId"]
    Chef::Log.info("ENI ID: " + eni_id)
    eni_id
  end

  def assign_secondary_ip()
    Chef::Log.info("Assigning Secondary IP: #{@secondary_private_ip}")
    eni_id = get_eni_id()
    assign = `aws ec2 assign-private-ip-addresses \
            --network-interface-id #{eni_id} \
            --private-ip-addresses #{@secondary_private_ip} \
            --allow-reassignment`
    Chef::Log.info("IP assignment output:" + assign)
  end
end


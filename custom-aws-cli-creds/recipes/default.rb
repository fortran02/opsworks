
directory "#{node['custom-aws-cli-creds']['config-dir']}" do
  mode "0755"
end

cli_config = ::File.join(node['custom-aws-cli-creds']['config-dir'], "aws_cli_config")
template cli_config do
  source "config.erb"
  mode "0440"
  variables(
    :ec2region => node["custom-aws-cli-creds"][:ec2region],
    :ec2key => node["custom-aws-cli-creds"][:ec2key],
    :ec2secret => node["custom-aws-cli-creds"][:ec2secret]
  )
end


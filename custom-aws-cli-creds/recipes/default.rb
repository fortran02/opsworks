
ruby_block "set_env_aws_cli_config" do
  block do
    ENV["AWS_CONFIG_FILE"] = ::File.join(node['custom-aws-cli-creds']['config-dir'], "aws_cli_config")
  end
  action :nothing
end

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
  notifies :create, "ruby_block[set_env_aws_cli_config]", :immediately
end


# recipes/default.rb
#
# Copyright 2014, Cascadeo Corp.

execute "fix-fileperm-ex" do
  command "chown -R #{node[:exhibitor][:user]}:#{node[:exhibitor][:group]} #{node[:exhibitor][:install_dir]}"
  action :nothing
end


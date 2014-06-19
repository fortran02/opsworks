# recipes/default.rb
#
# Copyright 2014, Cascadeo Corp.

zk_server_script = ::File.join(node[:zookeeper][:install_dir],
                          "zookeeper-#{node[:zookeeper][:version]}",
                          'bin',
                          'zkServer.sh')

template zk_server_script do
    source "zkServer.sh.erb"
    owner node[:zookeeper][:user]
    mode "0755"
    variables ({
      :transaction_dir => node[:exhibitor][:transaction_dir],
      :jvm_min_heap_mem => node[:zookeeper][:jvm_min_heap_mem],
      :jvm_max_heap_mem => node[:zookeeper][:jvm_max_heap_mem]
    })
end

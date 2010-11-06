cookbook_file "/etc/sysconfig/iptables" do
  source "iptables"
end

execute "restart iptables" do  #TODO only do this if the file changes
  command "/etc/init.d/iptables restart"
end

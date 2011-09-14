if platform?("centos")

  cookbook_file "/etc/sysconfig/iptables" do
    source "iptables"
    notifies :run, "execute[restart iptables]", :immediately
  end

  execute "restart iptables" do
    command "/etc/init.d/iptables restart"
  end

end

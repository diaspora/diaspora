execute "bundler deps" do
  command "yum install -y cpio"
end
execute "nokogiri deps" do
  command "yum install -y libxml2-devel libxslt-devel"
end
execute "eventmachine deps" do
  command "yum install -y gcc-c++"
end
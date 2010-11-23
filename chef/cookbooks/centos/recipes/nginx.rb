execute "pcre dependency" do
  command "yum install -y pcre-devel"
end
include_recipe "common::nginx"

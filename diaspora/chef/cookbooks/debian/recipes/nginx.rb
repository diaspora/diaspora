execute "pcre dependency" do
  command "apt-get install -y libpcre3 libpcre3-dev"
end
include_recipe "common::nginx"

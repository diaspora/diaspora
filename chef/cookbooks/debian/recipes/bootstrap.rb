execute "bundler deps" do
  command "apt-get install -y cpio"
end
execute "nokogiri deps" do
  command "apt-get install -y libxml2-dev libxslt-dev"
end

execute "eventmachine deps" do
  command "apt-get install -y gcc-c++"
end

execute "ssl lib" do
  command "apt-get install -y libssl-dev libopenssl-ruby"
end

execute "curl" do
  command "apt-get install -y libcurl4-openssl-dev"
end

execute "ffi" do
  command "apt-get install -y libffi-ruby"
end


execute "htop" do
  command "apt-get install -y htop psmisc screen"
end

execute "rvm deps" do
  command "apt-get install -y bzip2"
end

def harden_ruby(ruby_string)
  Dir.glob("/usr/local/rvm/wrappers/#{ruby_string}/*").each do |file|
    link "/usr/local/bin/#{file.split('/').last}" do
      to file
    end
  end
  Dir.glob("/usr/local/rvm/gems/#{ruby_string}/bin/*").each do |file|
    link "/usr/local/bin/#{file.split('/').last}" do
      to file
    end
  end

end

harden_ruby("ree-1.8.7-2010.02")

include_recipe "debian::post_bootstrap"

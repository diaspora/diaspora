common_pkgs = [
  "cpio",
  "gcc-c++",
  "htop",
  "psmisc",
  "screen",
  "bzip2"
]

dev_pkgs = value_for_platform(
  "debian" => {
    "default" => [
      "libxml2-dev",
      "libxslt1-dev",
      "libsqlite3-dev",
      "libmysqlclient-dev",
      "libssl-dev",
      "libcurl4-openssl-dev"
    ]
  },
  "centos" => {
    "default" => [
      "libxml2-devel",
      "libxslt-devel",
      "openssl-devel",
    ]
  }
)

execute "apt-get update" do
  action :nothing
end.run_action(:run) if platform?("debian")

common_pkgs.each do |pkg|
  package pkg
end

dev_pkgs do |pkg|
  package pkg
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

include_recipe "diaspora::java"

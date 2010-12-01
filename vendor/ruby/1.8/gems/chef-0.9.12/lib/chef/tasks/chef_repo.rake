#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008, 2009 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rubygems'
require 'json'
require 'chef'
require 'chef/role'
require 'chef/cookbook/metadata'
require 'tempfile'
require 'rake'

# Allow REMOTE options to be overridden on the command line
REMOTE_HOST = ENV["REMOTE_HOST"] if ENV["REMOTE_HOST"] != nil
REMOTE_SUDO = ENV["REMOTE_SUDO"] if ENV["REMOTE_SUDO"] != nil
if defined? REMOTE_HOST
  REMOTE_PATH_PREFIX = "#{REMOTE_HOST}:"
  REMOTE_EXEC_PREFIX = "ssh #{REMOTE_HOST}"
  REMOTE_EXEC_PREFIX += " sudo" if defined? REMOTE_SUDO
  LOCAL_EXEC_PREFIX = ""
else
  REMOTE_PATH_PREFIX = ""
  REMOTE_EXEC_PREFIX = ""
  LOCAL_EXEC_PREFIX = "sudo"
end

desc "Update your repository from source control"
task :update do
  puts "** Updating your repository"

  case $vcs
  when :svn
    sh %{svn up}
  when :git
    pull = false
    IO.foreach(File.join(TOPDIR, ".git", "config")) do |line|
      pull = true if line =~ /\[remote "origin"\]/
    end
    if pull
      sh %{git pull} 
    else
      puts "* Skipping git pull, no origin specified"
    end
  else
    puts "* No SCM configured, skipping update"
  end
end

desc "Install the latest copy of the repository on this Chef Server"
task :install => [ :update, :roles, :upload_cookbooks ] do
  if File.exists?(File.join(TOPDIR, "config", "server.rb"))
    puts "* Installing new Chef Server Config"
    sh "#{LOCAL_EXEC_PREFIX} rsync -rlt --delete --exclude '.svn' --exclude '.git*' config/server.rb #{REMOTE_PATH_PREFIX}#{CHEF_SERVER_CONFIG}"
  end
  if File.exists?(File.join(TOPDIR, "config", "client.rb"))
    puts "* Installing new Chef Client Config"
    sh "#{LOCAL_EXEC_PREFIX} rsync -rlt --delete --exclude '.svn' --exclude '.git*' config/client.rb #{REMOTE_PATH_PREFIX}#{CHEF_CLIENT_CONFIG}"
  end
end

desc "By default, run rake test_cookbooks"
task :default => [ :test_cookbooks ]

desc "Create a new cookbook (with COOKBOOK=name, optional CB_PREFIX=site-)"
task :new_cookbook do
  puts "***WARN: rake new_cookbook is deprecated. Please use 'knife cookbook new COOKBOOK' command.***"
  create_cookbook(File.join(TOPDIR, "#{ENV["CB_PREFIX"]}cookbooks"))
  create_readme(File.join(TOPDIR, "#{ENV["CB_PREFIX"]}cookbooks"))
  create_metadata(File.join(TOPDIR, "#{ENV["CB_PREFIX"]}cookbooks"))
end

def create_cookbook(dir)
  raise "Must provide a COOKBOOK=" unless ENV["COOKBOOK"]
  puts "** Creating cookbook #{ENV["COOKBOOK"]}"
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "attributes")}" 
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "recipes")}" 
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "definitions")}" 
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "libraries")}" 
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "resources")}" 
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "providers")}" 
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "files", "default")}" 
  sh "mkdir -p #{File.join(dir, ENV["COOKBOOK"], "templates", "default")}" 
  unless File.exists?(File.join(dir, ENV["COOKBOOK"], "recipes", "default.rb"))
    open(File.join(dir, ENV["COOKBOOK"], "recipes", "default.rb"), "w") do |file|
      file.puts <<-EOH
#
# Cookbook Name:: #{ENV["COOKBOOK"]}
# Recipe:: default
#
# Copyright #{Time.now.year}, #{COMPANY_NAME}
#
EOH
      case NEW_COOKBOOK_LICENSE
      when :apachev2
        file.puts <<-EOH
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
EOH
      when :none
        file.puts <<-EOH
# All rights reserved - Do Not Redistribute
#
EOH
      end
    end
  end
end

def create_readme(dir)
  raise "Must provide a COOKBOOK=" unless ENV["COOKBOOK"]
  puts "** Creating README for cookbook: #{ENV["COOKBOOK"]}"
  unless File.exists?(File.join(dir, ENV["COOKBOOK"], "README.rdoc"))
    open(File.join(dir, ENV["COOKBOOK"], "README.rdoc"), "w") do |file|
      file.puts <<-EOH
= DESCRIPTION:

= REQUIREMENTS:

= ATTRIBUTES: 

= USAGE:

EOH
    end
  end
end

def create_metadata(dir)
  raise "Must provide a COOKBOOK=" unless ENV["COOKBOOK"]
  puts "** Creating metadata for cookbook: #{ENV["COOKBOOK"]}"
  
  case NEW_COOKBOOK_LICENSE
  when :apachev2
    license = "Apache 2.0"
  when :none
    license = "All rights reserved"
  end

  unless File.exists?(File.join(dir, ENV["COOKBOOK"], "metadata.rb"))
    open(File.join(dir, ENV["COOKBOOK"], "metadata.rb"), "w") do |file|
      if File.exists?(File.join(dir, ENV["COOKBOOK"], 'README.rdoc'))
        long_description = "long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))"
      end
      file.puts <<-EOH
maintainer       "#{COMPANY_NAME}"
maintainer_email "#{SSL_EMAIL_ADDRESS}"
license          "#{license}"
description      "Installs/Configures #{ENV["COOKBOOK"]}"
#{long_description}
version          "0.1"
EOH
    end
  end
end

desc "Create a new self-signed SSL certificate for FQDN=foo.example.com"
task :ssl_cert do
  $expect_verbose = true
  fqdn = ENV["FQDN"]
  fqdn =~ /^(.+?)\.(.+)$/
  hostname = $1
  domain = $2
  keyfile = fqdn.gsub("*", "wildcard")
  raise "Must provide FQDN!" unless fqdn && hostname && domain
  puts "** Creating self signed SSL Certificate for #{fqdn}"
  sh("(cd #{CADIR} && openssl genrsa 2048 > #{keyfile}.key)")
  sh("(cd #{CADIR} && chmod 644 #{keyfile}.key)")
  puts "* Generating Self Signed Certificate Request"
  tf = Tempfile.new("#{keyfile}.ssl-conf")
  ssl_config = <<EOH
[ req ]
distinguished_name = req_distinguished_name
prompt = no

[ req_distinguished_name ]
C                      = #{SSL_COUNTRY_NAME}
ST                     = #{SSL_STATE_NAME}
L                      = #{SSL_LOCALITY_NAME}
O                      = #{COMPANY_NAME}
OU                     = #{SSL_ORGANIZATIONAL_UNIT_NAME}
CN                     = #{fqdn}
emailAddress           = #{SSL_EMAIL_ADDRESS}
EOH
  tf.puts(ssl_config)
  tf.close
  sh("(cd #{CADIR} && openssl req -config '#{tf.path}' -new -x509 -nodes -sha1 -days 3650 -key #{keyfile}.key > #{keyfile}.crt)")
  sh("(cd #{CADIR} && openssl x509 -noout -fingerprint -text < #{keyfile}.crt > #{keyfile}.info)")
  sh("(cd #{CADIR} && cat #{keyfile}.crt #{keyfile}.key > #{keyfile}.pem)")
  sh("(cd #{CADIR} && chmod 644 #{keyfile}.pem)")
end

rule(%r{\b(?:site-)?cookbooks/[^/]+/metadata\.json\Z} => [ proc { |task_name| task_name.sub(/\.[^.]+$/, '.rb') } ]) do |t|
  system("knife cookbook metadata from file #{t.source}")
end

desc "Build cookbook metadata.json from metadata.rb"
task :metadata => FileList[File.join(TOPDIR, '*cookbooks', ENV['COOKBOOK'] || '*', 'metadata.rb')].pathmap('%X.json')

rule(%r{\broles/\S+\.json\Z} => [ proc { |task_name| task_name.sub(/\.[^.]+$/, '.rb') } ]) do |t|
  system("knife role from file #{t.source}")
end

desc "Update roles"
task :roles  => FileList[File.join(TOPDIR, 'roles', '**', '*.rb')].pathmap('%X.json')

desc "Update a specific role"
task :role, :role_name do |t, args|
  system("knife role from file #{File.join(TOPDIR, 'roles', args.role_name)}.rb")
end

desc "Upload all cookbooks"
task :upload_cookbooks => [ :metadata ]
task :upload_cookbooks do
  system("knife cookbook upload --all")
end

desc "Upload a single cookbook"
task :upload_cookbook => [ :metadata ]
task :upload_cookbook, :cookbook do |t, args|
  system("knife cookbook upload #{args.cookbook}")
end

desc "Test all cookbooks"
task :test_cookbooks do
  system("knife cookbook test --all")
end

desc "Test a single cookbook"
task :test_cookbook, :cookbook do |t, args|
  system("knife cookbook test #{args.cookbook}")
end


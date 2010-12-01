#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Christopher Brown (<cb@opscode.com>)
# Author:: AJ Christensen (<aj@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

require 'chef/log'
require 'mixlib/config'

class Chef
  class Config

    extend Mixlib::Config

    # Manages the chef secret session key
    # === Returns
    # <newkey>:: A new or retrieved session key
    #
    def self.manage_secret_key
      newkey = nil
      if Chef::FileCache.has_key?("chef_server_cookie_id")
        newkey = Chef::FileCache.load("chef_server_cookie_id")
      else
        chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
        newkey = ""
        40.times { |i| newkey << chars[rand(chars.size-1)] }
        Chef::FileCache.store("chef_server_cookie_id", newkey)
      end
      newkey
    end

    def self.inspect
      configuration.inspect
    end

    # Override the config dispatch to set the value of multiple server options simultaneously
    #
    # === Parameters
    # url<String>:: String to be set for all of the chef-server-api URL's
    #
    config_attr_writer :chef_server_url do |url|
      configure do |c|
        [ :registration_url,
          :template_url,
          :remotefile_url,
          :search_url,
          :chef_server_url,
          :role_url ].each do |u|
            c[u] = url
        end
      end
      url
    end

    # When you are using ActiveSupport, they monkey-patch 'daemonize' into Kernel.
    # So while this is basically identical to what method_missing would do, we pull
    # it up here and get a real method written so that things get dispatched
    # properly.
    config_attr_writer :daemonize do |v|
      configure do |c|
        c[:daemonize] = v
      end
    end

    # Override the config dispatch to set the value of log_location configuration option
    #
    # === Parameters
    # location<IO||String>:: Logging location as either an IO stream or string representing log file path
    #
    config_attr_writer :log_location do |location|
      if location.respond_to? :sync=
        location
      elsif location.respond_to? :to_str
        f = File.new(location.to_str, "a")
        f.sync = true
        f
      end
    end

    # Override the config dispatch to set the value of authorized_openid_providers when openid_providers (deprecated) is used
    #
    # === Parameters
    # providers<Array>:: An array of openid providers that are authorized to login to the chef server
    #
    config_attr_writer :openid_providers do |providers|
      configure { |c| c[:authorized_openid_providers] = providers }
      providers
    end

    # Used when OpenID authentication is enabled in the Web UI
    authorized_openid_identifiers nil
    authorized_openid_providers nil
    openid_cstore_couchdb false
    openid_cstore_path "/var/chef/openid/cstore"

    # The number of times the client should retry when registering with the server
    client_registration_retries 5

    # Where the cookbooks are located. Meaning is somewhat context dependent between
    # knife, chef-client, and chef-solo.
    cookbook_path [ "/var/chef/cookbooks", "/var/chef/site-cookbooks" ]

    # Where files are stored temporarily during uploads
    sandbox_path "/var/chef/sandboxes"

    # Where cookbook files are stored on the server (by content checksum)
    checksum_path "/var/chef/checksums"

    # CouchDB database name to use
    couchdb_database "chef"

    couchdb_url "http://localhost:5984"

    # Where chef's cache files should be stored
    file_cache_path "/var/chef/cache"

    # Where backups of chef-managed files should go
    file_backup_path "/var/chef/backup"

    ## Daemonization Settings ##
    # What user should Chef run as?
    user nil
    # What group should the chef-server, -solr, -solr-indexer run as
    group nil
    umask 0022

    http_retry_count 5
    http_retry_delay 5
    interval nil
    json_attribs nil
    log_level :info
    log_location STDOUT
    verbose_logging nil
    node_name nil
    node_path "/var/chef/node"

    pid_file nil

    chef_server_url   "http://localhost:4000"
    registration_url  "http://localhost:4000"
    template_url      "http://localhost:4000"
    role_url          "http://localhost:4000"
    remotefile_url    "http://localhost:4000"
    search_url        "http://localhost:4000"

    client_url "http://localhost:4042"

    rest_timeout 300
    run_command_stderr_timeout 120
    run_command_stdout_timeout 120
    solo  false
    splay nil

    # Set these to enable SSL authentication / mutual-authentication
    # with the server
    ssl_client_cert nil
    ssl_client_key nil
    ssl_verify_mode :verify_none
    ssl_ca_path nil
    ssl_ca_file nil


    # Where should chef-solo look for role files?
    role_path "/var/chef/roles"

    # Where should chef-solo download recipes from?
    recipe_url nil

    solr_url "http://localhost:8983"
    solr_jetty_path "/var/chef/solr-jetty"
    solr_data_path "/var/chef/solr/data"
    solr_home_path "/var/chef/solr"
    solr_heap_size "256M"
    solr_java_opts nil

    # Parameters for connecting to RabbitMQ
    amqp_host '0.0.0.0'
    amqp_port '5672'
    amqp_user 'chef'
    amqp_pass 'testing'
    amqp_vhost '/chef'
    # Setting this to a UUID string also makes the queue durable
    # (persist across rabbitmq restarts)
    amqp_consumer_id "default"

    client_key "/etc/chef/client.pem"
    validation_key "/etc/chef/validation.pem"
    validation_client_name "chef-validator"
    web_ui_client_name "chef-webui"
    web_ui_key "/etc/chef/webui.pem"
    web_ui_admin_user_name  "admin"
    web_ui_admin_default_password "p@ssw0rd1"

    # Server Signing CA
    #
    # In truth, these don't even have to change
    signing_ca_cert "/var/chef/ca/cert.pem"
    signing_ca_key "/var/chef/ca/key.pem"
    signing_ca_user nil
    signing_ca_group nil
    signing_ca_country "US"
    signing_ca_state "Washington"
    signing_ca_location "Seattle"
    signing_ca_org "Chef User"
    signing_ca_domain "opensource.opscode.com"
    signing_ca_email "opensource-cert@opscode.com"

    # Report Handlers
    report_handlers []

    # Exception Handlers
    exception_handlers []

    # Checksum Cache
    # Uses Moneta on the back-end
    cache_type "BasicFile"
    cache_options({ :path => "/var/chef/cache/checksums", :skip_expires => true })

    # Arbitrary knife configuration data
    knife Hash.new

    # Those lists of regular expressions define what chef considers a
    # valid user and group name
    user_valid_regex [ /^([-a-zA-Z0-9_.]+)$/, /^\d+$/ ]
    group_valid_regex [ /^([-a-zA-Z0-9_.]+)$/, /^\d+$/ ]
  end
end

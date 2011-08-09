# Copyright (c) 2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.
require 'uri'

class AppConfig < Settingslogic

  def self.source_file_name
    if Rails.env == 'test' || ENV["CI"] || Rails.env.include?("integration")
      File.join(Rails.root, "config", "application.yml.example")
    else
      File.join(Rails.root, "config", "application.yml")
    end
  end
  source source_file_name
  namespace Rails.env

  def self.load!
    if no_config_file? && !have_old_config_file?
      $stderr.puts <<-HELP
******** You haven't set up your Diaspora settings file. **********
Please do the following:
1. Copy config/application.yml.example to config/application.yml.
2. Have a look at the settings in that file. It has sensible defaults for development, which (we hope)
work without modification. However, it's always good to know what's available to change later.
3. Restart Diaspora!
******** Thanks for being an alpha tester! **********
HELP
      Process.exit(1)
    end

    if (no_config_file? && have_old_config_file?) || config_file_is_old_style?
      $stderr.puts <<-HELP
******** The Diaspora configuration file format has changed. **********
Please do the following:
1. Copy config/application.yml.example to config/application.yml.
2. Make any changes in config/application.yml that you previously made in config/app.yml or config/app_config.yml.
3. Delete config/app.yml and config/app_config.yml. Don't worry if they don't exist, though.
4. Restart Diaspora!
******** Thanks for being an alpha tester! **********
HELP
      Process.exit(1)
    end

    super

    if no_cert_file_in_prod?
      $stderr.puts <<-HELP
******** Diaspora does not know where your SSL-CA-Certificates file is. **********
  Please add the root certificate bundle (this is operating system specific) to application.yml. Defaults:
    CentOS: '/etc/pki/tls/certs/ca-bundle.crt'
    Debian: '/etc/ssl/certs/ca-certificates.crt'

  Example:
    ca_file: '/etc/ssl/certs/ca-certificates.crt'
******** Thanks for being secure! **********
HELP
      Process.exit(1)
    end

    normalize_pod_url
    normalize_admins
    normalize_pod_services
  end

  def self.config_file_is_old_style?
    !(File.read(@source) =~ /^defaults: &defaults/)
  end

  def self.no_config_file?
    !File.exists?(@source)
  end

  def self.no_cert_file_in_prod?
    (Rails.env == "production") && self[:ca_file] && !File.exists?(self[:ca_file])
  end

  def self.have_old_config_file?
    File.exists?(File.join(Rails.root, "config", "app.yml")) || (File.exists?(File.join(Rails.root, "config", "app_config.yml")))
  end

  def self.normalize_pod_url
    unless self[:pod_url] =~ /^(https?:\/\/)/ # starts with http:// or https://
      self[:pod_url] = "http://#{self[:pod_url]}"
    end
    unless self[:pod_url] =~ /\/$/ # ends with slash
      self[:pod_url] = "#{self[:pod_url]}/"
    end
  end

  def self.normalize_admins
    self[:admins] ||= []
    self[:admins].collect! { |username| username.downcase }
  end

  def self.normalize_pod_services
    if defined?(SERVICES)
      configured_services = []
      SERVICES.keys.each do |service|
        unless SERVICES[service].keys.any?{|service_key| SERVICES[service][service_key].blank?}
          configured_services << service
        end
      end
      self['configured_services'] = configured_services
    end
  end

  load!

  def self.[] (key)
    return self.pod_uri if key == :pod_uri
    super
  end

  def self.[]= (key, value)
    super
    if key.to_sym == :pod_url
      @@pod_uri = nil
      normalize_pod_url
    end
  end

  cattr_accessor :pod_uri

  def self.pod_uri
    if @@pod_uri.nil?
      begin
        @@pod_uri = Addressable::URI.parse(self.pod_url)
      rescue
        puts "WARNING: pod url " + self.pod_url + " is not a legal URI"
      end
    end
    return @@pod_uri
  end
end

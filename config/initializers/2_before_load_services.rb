#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

def load_config_yaml filename
  YAML.load(ERB.new(File.read(filename)).result)
end

oauth_keys_file = "#{Rails.root}/config/oauth_keys.yml"


SERVICES = load_config_yaml("#{oauth_keys_file}.example")

#this is to be backwards compatible with current production setups
if File.exist? oauth_keys_file
  ActiveSupport::Deprecation.warn("01/05/2012 keys in oauth_keys.yml should be moved into application.yml. SEE application.yml.example for updated key names")
  SERVICES.deep_merge!(load_config_yaml(oauth_keys_file))
end

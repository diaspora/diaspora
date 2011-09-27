#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

def load_config_yaml filename
  YAML.load(File.read(filename))
end

oauth_keys_file = "#{Rails.root}/config/oauth_keys.yml"


SERVICES = nil
silence_warnings do
  SERVICES = load_config_yaml("#{oauth_keys_file}.example")
  if File.exist? oauth_keys_file
    SERVICES.deep_merge!(load_config_yaml(oauth_keys_file))
  end
end

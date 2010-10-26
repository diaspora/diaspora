#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

def load_config_yaml filename
  YAML.load(File.read(filename))
end

oauth_keys_file = "#{Rails.root}/config/oauth_keys.yml"

if File.exist? oauth_keys_file
  SERVICES = load_config_yaml(oauth_keys_file)
end

SERVICES ||= load_config_yaml("#{oauth_keys_file}.example")


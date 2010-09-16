#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


raw_config = File.read("#{Rails.root}/config/app_config.yml")
APP_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys

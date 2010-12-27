# Copyright (c) 2010, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.
#
# Sets up AppConfig. Unless stated below, each entry is a the string in
# the file app_config.yml, as applicable for current environment.
#
# Specific items
#   * pod_url: As in app_config.yml, normalized with a trailing /.
#   * pod_uri: An uri object derived from pod_url.

require File.join(Rails.root, 'lib', 'app_config')

AppConfig.configure_for_environment(Rails.env)

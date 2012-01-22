# Copyright (c) 2012, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

if EnviromentConfiguration.using_new_relic?
  require 'newrelic_rpm'
end

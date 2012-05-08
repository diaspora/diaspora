#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

load 'deploy' if respond_to?(:namespace) # cap2 differentiator
# Precompile assets in deployment (for Capistrano >= 2.8.0)
load 'deploy/assets' if respond_to?(:namespace)

Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy' # remove this line to skip loading any of the default tasks

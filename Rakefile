#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
ENV['GNUPGHOME'] = File.expand_path("../../gpg/diaspora-#{Rails.env}/", __FILE__)
Diaspora::Application.load_tasks

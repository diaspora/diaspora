# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

ENV["RAILS_ASSET_ID"] = AppConfig.rails_asset_id if Rails.env.production? && ! AppConfig.heroku?

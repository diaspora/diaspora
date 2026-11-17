# frozen_string_literal: true

# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

if AppConfig.environment.require_ssl?
  Rails.application.config.force_ssl = true
  Rails.logger.info("Force SSL is enabled")
elsif Rails.env.production?
  Rails.application.config.force_ssl = false
  Rails.logger.info("Force SSL is disabled")
end

# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class Base
    include Sidekiq::Worker
    sidekiq_options backtrace: (bt = AppConfig.environment.sidekiq.backtrace.get) && bt.to_i,
                    retry:     (rt = AppConfig.environment.sidekiq.retry.get) && rt.to_i

    include Diaspora::Logging
  end
end

# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# This file is used by Rack-based servers to start the application.

require ::File.expand_path("../config/environment",  __FILE__)

# Kill unicorn workers really aggressively (at 300mb)
if defined?(Unicorn)
  require "unicorn/worker_killer"
  oom_min = (280) * (1024**2)
  oom_max = (300) * (1024**2)
  # Max memory size (RSS) per worker
  use Unicorn::WorkerKiller::Oom, oom_min, oom_max
end
use Rack::Deflater

run Diaspora::Application

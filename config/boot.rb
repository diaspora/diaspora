# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Load configuration early
require_relative "load_config"

# Ruby 3.2 removed the `exists?` alias from `File`, but at least the `logging-rails` gem still uses it.
# This is only a workaround, and we need a different long-term solution. It looks like the `logging-rails` gem
# is not maintained anymore, so we maybe need to find a replacement. But since this is the only thing preventing
# us from upgrading to Ruby >= 3.2, we can just create our own alias for now.
class << File
  alias exists? exist?
end

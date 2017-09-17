# frozen_string_literal: true

module SidekiqMiddlewares
  class CleanAndShortBacktraces
    def call(worker, item, queue)
      yield
    rescue Exception
      backtrace = Rails.backtrace_cleaner.clean($!.backtrace)
      backtrace.reject! { |line| line =~ /lib\/sidekiq_middlewares.rb/ }
      limit = AppConfig.environment.sidekiq.backtrace.get
      limit = limit ? limit.to_i : 0
      backtrace = [] if limit == 0
      raise $!, $!.message, backtrace[0..limit]
    end
  end
end

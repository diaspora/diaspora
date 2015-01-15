module SidekiqMiddlewares
  class CleanAndShortBacktraces
    def call(_worker, _item, _queue)
      yield
    rescue Exception
      backtrace = Rails.backtrace_cleaner.clean($ERROR_INFO.backtrace)
      backtrace.reject! { |line| line =~ /lib\/sidekiq_middlewares.rb/ }
      limit = AppConfig.environment.sidekiq.backtrace.get
      limit = limit ? limit.to_i : 0
      backtrace = [] if limit == 0
      raise $ERROR_INFO, $ERROR_INFO.message, backtrace[0..limit]
    end
  end
end

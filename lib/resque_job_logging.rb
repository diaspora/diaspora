module ResqueJobLogging
  def around_perform_log_job(*args)
    Rails.logger.auto_flushing=1
    log_string = "event=resque_job job=#{self} "
    error = nil
    time = Benchmark.realtime{
      begin
        yield
      rescue Exception => e
        error = e
      end
    }*1000
    if error
      log_string += "status=error "
      log_string << "error_class=#{error.class} error_message='#{error.message}' "
      log_string << "orig_error_message='#{error.original_error.message}'" if error.respond_to?(:original_error)
      log_string << "annotated_source='#{error.annoted_source_code.to_s}' " if error.respond_to?(:annoted_source_code)
      log_string << "app_backtrace='#{application_trace(error).join(";")}' "
    else
      log_string += "status=complete "
    end
    log_string += "ms=#{time} "
    args.each_with_index{|arg,idx| log_string += "arg#{idx.succ}=\"#{arg.to_s[0..30]}\" "}

    Rails.logger.info(log_string)
    if error
      notify_hoptoad(error, args) if AppConfig[:hoptoad_api_key].present? && Rails.env.production?
      raise error
    end
  end

  def notify_hoptoad error
    HoptoadNotifier.notify(
      :error_class => error.class,
      :error_message => error.message,
      :parameters => {
        :job_class => self.name,
        :arguments => args
      }
    )
  end

  def application_trace(error) #copied from ActionDispatch::ShowExceptions
       defined?(Rails) && Rails.respond_to?(:backtrace_cleaner) ?
          Rails.backtrace_cleaner.clean(error.backtrace, :silent) :
          error.backtrace
  end
end

module HelperMethods
  def inlined_jobs
    Sidekiq::Worker.clear_all
    result = yield Sidekiq::Worker
    Sidekiq::Worker.drain_all
    result
  rescue NoMethodError
    yield Sidekiq::Worker if block_given? # Never error out on our own
  end
end

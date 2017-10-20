# frozen_string_literal: true

module HelperMethods
  def inlined_jobs
    Sidekiq::Worker.clear_all
    result = yield Sidekiq::Worker
    Sidekiq::Worker.drain_all
    result
  end
end

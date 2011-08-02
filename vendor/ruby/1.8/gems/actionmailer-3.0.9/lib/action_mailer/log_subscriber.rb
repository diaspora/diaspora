require 'active_support/core_ext/array/wrap'

module ActionMailer
  class LogSubscriber < ActiveSupport::LogSubscriber
    def deliver(event)
      recipients = Array.wrap(event.payload[:to]).join(', ')
      info("\nSent mail to #{recipients} (%1.fms)" % event.duration)
      debug(event.payload[:mail])
    end

    def receive(event)
      info("\nReceived mail (%.1fms)" % event.duration)
      debug(event.payload[:mail])
    end

    def logger
      ActionMailer::Base.logger
    end
  end
end

ActionMailer::LogSubscriber.attach_to :action_mailer
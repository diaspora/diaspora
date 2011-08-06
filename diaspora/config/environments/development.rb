#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

Diaspora::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  #config.threadsafe!

  # Monkeypatch around the nasty "2.5MB exception page" issue, caused by very large environment vars
  # This snippet via: http://stackoverflow.com/questions/3114993/exception-pages-in-development-mode-take-upwards-of-15-30-seconds-to-render-why
  # Relevant Rails ticket: https://rails.lighthouseapp.com/projects/8994/tickets/5027-_request_and_responseerb-and-diagnosticserb-take-an-increasingly-long-time-to-render-in-development-with-multiple-show-tables-calls
  config.after_initialize do
    module SmallInspect
      def inspect
        "<#{self.class.name} - tooooo long>"
      end
    end
    [ActionController::Base, ActionDispatch::RemoteIp::RemoteIpGetter, OmniAuth::Strategy, Warden::Proxy].each do |klazz|
      klazz.send(:include, SmallInspect)
    end
  end
end

begin
  require 'webrat'
rescue LoadError
end

RSpec.configure do |c|
  if defined?(Webrat)
    c.include Webrat::Matchers, :type => :request
    c.include Webrat::Matchers, :type => :controller
    c.include Webrat::Matchers, :type => :view
    c.include Webrat::Matchers, :type => :helper
    c.include Webrat::Matchers, :type => :mailer

    c.include Webrat::Methods,  :type => :request
    c.include Webrat::Methods,  :type => :controller

    module RequestInstanceMethods
      def last_response
        @response
      end
    end

    c.include RequestInstanceMethods, :type => :request

    c.before :type => :controller do
      Webrat.configure {|c| c.mode = :rails}
    end

    c.before :type => :request do
      Webrat.configure {|c| c.mode = :rack}
    end
  end
end

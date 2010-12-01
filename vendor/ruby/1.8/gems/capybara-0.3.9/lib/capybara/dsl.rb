require 'capybara'

module Capybara
  class << self
    attr_writer :default_driver, :current_driver, :javascript_driver

    attr_accessor :app

    def default_driver
      @default_driver || :rack_test
    end

    def current_driver
      @current_driver || default_driver
    end
    alias_method :mode, :current_driver

    def javascript_driver
      @javascript_driver || :selenium
    end

    def use_default_driver
      @current_driver = nil
    end

    def current_session
      session_pool["#{current_driver}#{app.object_id}"] ||= Capybara::Session.new(current_driver, app)
    end

    def current_session?
      session_pool.has_key?("#{current_driver}#{app.object_id}")
    end

    def reset_sessions!
      session_pool.each { |mode, session| session.cleanup! }
      @session_pool = nil
    end

  private

    def session_pool
      @session_pool ||= {}
    end
  end

  extend(self)

  def page
    Capybara.current_session
  end

  Session::DSL_METHODS.each do |method|
    class_eval <<-RUBY, __FILE__, __LINE__+1
      def #{method}(*args, &block)
        page.#{method}(*args, &block)
      end
    RUBY
  end

end


ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment') unless defined?(Rails)

require 'timeout'
require 'socket'
require 'singleton'

require 'capybara/rails'
require 'capybara/cucumber'
require 'capybara/session'

class TestServerFixture
# simple interface to script/server

  def self.is_port_open(host, port, tries)
    for i in (1..tries)
      begin
        Timeout::timeout(2) do
          begin
            s = TCPSocket.new(host, port)
            s.close
            return  true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            sleep( 2)
          end
        end
      rescue Timeout::Error
        return false
      end
    end
    return false
  end

  def self.start_if_needed
    unless TestServerFixture.is_port_open( "localhost", 3000, 2)
      system( "script/server -d")
      if TestServerFixture.is_port_open( "localhost", 3000, 30)
        puts "script/server started"
      else
        puts "Error: can't start script/server"
      end
    end
  end

end

class CapybaraSettings
# simple save/restore for Capybara

  include Singleton

  def save
    begin
      @run_server = Capybara.run_server
      @driver = Capybara.current_driver
      @host = Capybara.app_host
    rescue => e
      puts "Saving exception: " + e.inspect
    end
  end

  def restore
    begin
      Capybara.current_driver = @driver
      Capybara.app_host = @host
      Capybara.run_server = @run_server
    rescue => e
      puts "Restore exception: " + e.inspect
    end
  end

end

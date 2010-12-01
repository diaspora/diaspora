require File.dirname(__FILE__) + '/culerity/remote_object_proxy'
require File.dirname(__FILE__) + '/culerity/remote_browser_proxy'

Symbol.class_eval do
  def to_proc
    Proc.new{|object| object.send(self)}
  end
end unless :symbol.respond_to?(:to_proc)

module Culerity

  module ServerCommands
    def exit_server
      self << '["_exit_"]'
      Process.kill(6, self.pid.to_i)
    end

    def close_browsers
      self.puts '["_close_browsers_"]'
    end
    
    def clear_proxies
      self.puts '["_clear_proxies_"]'      
    end
  end
  
  def self.culerity_root
    File.expand_path('../../', __FILE__)
  end
  
  def self.celerity_invocation
    %{#{culerity_root}/lib/start_celerity.rb}
  end
  
  def self.jruby_invocation
    @jruby_invocation ||= (ENV["JRUBY_INVOCATION"] || "jruby")
  end
  
  def self.jruby_invocation=(invocation)
    @jruby_invocation = invocation
  end
  
  def self.run_server
    IO.popen(%{#{jruby_invocation} "#{celerity_invocation}"}, 'r+').extend(ServerCommands)
  end
  
  def self.run_rails(options = {})
    if defined?(Rails) && !File.exists?("tmp/culerity_rails_server.pid")
      puts "WARNING: Speed up execution by running 'rake culerity:rails:start'"
      port        = options[:port] || 3001
      environment = options[:environment] || 'culerity'
      rails_server = fork do
        $stdin.reopen "/dev/null"
        $stdout.reopen "/dev/null"
        $stderr.reopen "/dev/null"
        Dir.chdir(Rails.root) do
          exec "script/server -e #{environment} -p #{port}"
        end
      end
      sleep 5
      rails_server
    end
  end
end

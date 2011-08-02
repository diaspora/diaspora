dependencies = %w{
  bacon
  mocha/standalone
  mocha/object
  sinatra
}

begin
  dependencies.each {|f| require f }
rescue LoadError
  require 'rubygems'
  dependencies.each {|f| require f }
end

require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'vegas.rb')
require File.join(File.expand_path(File.dirname(__FILE__)), 'apps.rb')


module TestHelper

  def vegas(*args, &block)
    Vegas::Runner.any_instance.stubs(:daemonize!).once
    Rack::Handler::Thin.stubs(:run).once
    @vegas = Vegas::Runner.new(*args, &block)
  end

  def body
    last_response.body.to_s
  end

  def instance_of(klass)
    lambda {|obj| obj.is_a?(klass) }
  end

  def exist_as_file
    lambda {|obj| File.exist?(obj) }
  end

  def have_matching_file_content(content_regex)
    lambda {|obj|
      File.exist?(obj) && File.read(obj).match(content_regex)
    }
  end

  def html_body
    body =~ /^\<html/ ? body : "<html><body>#{body}</body></html>"
  end

end

module Bacon
  summary_on_exit
  # extend TestUnitOutput
  class Context; include TestHelper; end
end

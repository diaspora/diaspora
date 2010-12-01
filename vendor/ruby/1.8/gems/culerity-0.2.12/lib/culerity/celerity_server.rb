require 'rubygems'
require 'celerity'


module Culerity
  class CelerityServer
    
    def initialize(_in, _out)
      @proxies = {}
      @browsers = []

      while(true)
        call, block = eval _in.gets.to_s.strip
        return if call == "_exit_"
        next(close_browsers) if call == "_close_browsers_"
        next(clear_proxies) if call == "_clear_proxies_"
        
        unless call.nil?
          begin
            result = target(call.first).send call[1], *call[2..-1], &block
            _out << "[:return, #{proxify result}]\n"
          rescue => e
            _out << "[:exception, \"#{e.class.name}\", #{e.message.inspect}, #{e.backtrace.inspect}]\n"
          end
        end

      end
      
    end
    
    private
    
    def clear_proxies
      @proxies = {}
    end
    
    def configure_browser(options)
      @browser_options = options
    end
    
    def new_browser(options, number = nil)
      number ||= @browsers.size
      @browsers[number] = Celerity::Browser.new(options || @browser_options || {})
      "browser#{number}"
    end

    def close_browsers
      @browsers.each { |browser| browser.close }
      @browsers = []
      @proxies = {}
    end

    def browser(number)
      unless @browsers[number]
        new_browser(nil, number)
      end
      @browsers[number]
    end
    
    def target(object_id)
      if object_id =~ /browser(\d+)/
        browser($1.to_i)
      elsif object_id == 'celerity'
        self
      else
        @proxies[object_id]
      end
    end
    
    def proxify(result)
      if result.is_a?(Array)
        "[" + result.map {|x| proxify(x) }.join(", ") + "]"
      elsif [Symbol, String, TrueClass, FalseClass, Fixnum, Float, NilClass].include?(result.class)
        result.inspect
      else
        @proxies[result.object_id] = result
        "Culerity::RemoteObjectProxy.new(#{result.object_id}, @io)"
      end
    end
  end
end

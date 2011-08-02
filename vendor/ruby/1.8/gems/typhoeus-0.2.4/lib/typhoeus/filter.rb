module Typhoeus
  class Filter
    attr_reader :method_name
    
    def initialize(method_name, options = {})
      @method_name = method_name
      @options = options
    end
    
    def apply_filter?(method_name)
      if @options[:only]
        if @options[:only].instance_of? Symbol
          @options[:only] == method_name
        else
          @options[:only].include?(method_name)
        end
      elsif @options[:except]
        if @options[:except].instance_of? Symbol
          @options[:except] != method_name
        else
          !@options[:except].include?(method_name)
        end
      else
        true
      end
    end
  end
end
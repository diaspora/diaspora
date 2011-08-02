module Cucumber
  module Constantize #:nodoc:
    def constantize(camel_cased_word)
      try = 0
      begin
        try += 1
        names = camel_cased_word.split('::')
        names.shift if names.empty? || names.first.empty?

        constant = Object
        names.each do |name|
          constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
        end
        constant
      rescue NameError => e
        require underscore(camel_cased_word)
        if try < 2
          retry
        else
          raise e
        end
      end
    end

    # Snagged from active_support
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end
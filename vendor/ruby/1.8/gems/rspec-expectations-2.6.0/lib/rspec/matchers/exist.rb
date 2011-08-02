module RSpec
  module Matchers
    # :call-seq:
    #   should exist
    #   should_not exist
    #
    # Passes if actual.exist? or actual.exists?
    def exist(*args)
      Matcher.new :exist do
        match do |actual|
          predicates = [:exist?, :exists?].select { |p| actual.respond_to?(p) }
          existance_values = predicates.map { |p| actual.send(p, *args) }
          uniq_truthy_values = existance_values.map { |v| !!v }.uniq

          case uniq_truthy_values.size
            when 0; raise NoMethodError.new("#{actual.inspect} does not respond to either #exist? or #exists?")
            when 1; existance_values.first
            else raise "#exist? and #exists? returned different values:\n\n" +
                       " exist?: #{existance_values.first}\n" +
                       "exists?: #{existance_values.last}"
          end
        end
      end
    end
  end
end

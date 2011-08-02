class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.use_transactional_fixtures = true
  
  class << self
    def assertion(name, &block)
      mc = class << self ; self ; end
      mc.class_eval do
        define_method(name) do
          it(name, &block)
        end
      end
    end
    
    def asssertion_group(name, &block)
      mc = class << self ; self ; end
      mc.class_eval do
        define_method(name, &block)
      end
    end

    def macro(name, &block)
      class_eval do
        define_method(name, &block)
      end
    end
    
    def describe(description, toplevel=nil, &blk)
      text = toplevel ? description : "#{name} #{description}"
      klass = Class.new(self)

      klass.class_eval <<-RUBY_EVAL
        def self.name
          "#{text}"
        end
      RUBY_EVAL

      # do not inherit test methods from the superclass
      klass.class_eval do
        instance_methods.grep(/^test.+/) do |method|
          undef_method method
        end
      end

      klass.instance_eval &blk
    end
    alias_method :context, :describe
    
    def let(name, &blk)
      values = {}
      define_method(name) do
        return values[name] if values.has_key?(name)
        values[name] = instance_eval(&blk)
      end
    end
    
    def it(description, &blk)
      define_method("test: #{name} #{description}", &blk)
    end
  end
  
end

def describe(description, &blk)
  ActiveSupport::TestCase.describe(description, true, &blk)
end


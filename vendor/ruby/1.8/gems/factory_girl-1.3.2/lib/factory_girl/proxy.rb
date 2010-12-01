class Factory

  class Proxy #:nodoc:

    attr_reader :callbacks

    def initialize(klass)
    end

    def get(attribute)
      nil
    end

    def set(attribute, value)
    end

    def associate(name, factory, attributes)
    end

    def add_callback(name, block)
      @callbacks ||= {}
      @callbacks[name] ||= []
      @callbacks[name] << block
    end

    def run_callbacks(name)
      if @callbacks && @callbacks[name]
        @callbacks[name].each do |block|
          block.arity.zero? ? block.call : block.call(@instance)
        end
      end
    end

    # Generates an association using the current build strategy.
    #
    # Arguments:
    #   name: (Symbol)
    #     The name of the factory that should be used to generate this
    #     association.
    #   attributes: (Hash)
    #     A hash of attributes that should be overridden for this association.
    #
    # Returns:
    #   The generated association for the current build strategy. Note that
    #   associations are not generated for the attributes_for strategy. Returns
    #   nil in this case.
    #
    # Example:
    #
    #   Factory.define :user do |f|
    #     # ...
    #   end
    #
    #   Factory.define :post do |f|
    #     # ...
    #     f.author {|a| a.association :user, :name => 'Joe' }
    #   end
    #
    #   # Builds (but doesn't save) a Post and a User
    #   Factory.build(:post)
    #
    #   # Builds and saves a User, builds a Post, assigns the User to the
    #   # author association, and saves the User.
    #   Factory.create(:post)
    #
    def association(name, overrides = {})
      nil
    end

    def method_missing(method, *args, &block)
      get(method)
    end

    def result
      raise NotImplementedError, "Strategies must return a result"
    end
  end

end

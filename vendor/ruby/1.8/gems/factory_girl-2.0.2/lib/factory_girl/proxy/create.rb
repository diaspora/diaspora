module FactoryGirl
  class Proxy #:nodoc:
    class Create < Build #:nodoc:
      def result(to_create)
        run_callbacks(:after_build)
        if to_create
          to_create.call(@instance)
        else
          @instance.save!
        end
        run_callbacks(:after_create)
        @instance
      end
    end
  end
end

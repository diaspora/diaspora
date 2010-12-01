class Factory
  class Proxy #:nodoc:
    class Create < Build #:nodoc:
      def result
        run_callbacks(:after_build)
        @instance.save!
        run_callbacks(:after_create)
        @instance
      end
    end
  end
end

class LazyModule < Module
  def self.new(&blk)
    # passing no-op block overrides &blk
    m = super{ }
    class << m
      include ClassMethods
    end
    m.lazy_evaluated_body = blk
    m
  end

  module ClassMethods
    attr_accessor :lazy_evaluated_body
    def included(host)
      host.class_eval(&@lazy_evaluated_body)
    end
  end
end

module Extlib
  module Assertions
    def assert_kind_of(name, value, *klasses)
      klasses.each { |k| return if value.kind_of?(k) }
      raise ArgumentError, "+#{name}+ should be #{klasses.map { |k| k.name } * ' or '}, but was #{value.class.name}", caller(2)
    end
  end
end

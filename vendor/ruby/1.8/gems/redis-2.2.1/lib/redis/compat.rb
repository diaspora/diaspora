# This file contains core methods that are present in
# Ruby 1.9 and not in earlier versions.

unless [].respond_to?(:product)
  class Array
    def product(*enums)
      enums.unshift self
      result = [[]]
      while [] != enums
        t, result = result, []
        b, *enums = enums
        t.each do |a|
          b.each do |n|
            result << a + [n]
          end
        end
      end
      result
    end
  end
end

Shindo.tests('test_helper', 'meta') do

  tests('#formats_kernel') do

    tests('returns true') do

      test('when format of value matches') do
        formats_kernel({:a => :b}, {:a => Symbol})
      end

      test('when format of nested array elements matches') do
        formats_kernel({:a => [:b, :c]}, {:a => [Symbol]})
      end

      test('when format of nested hash matches') do
        formats_kernel({:a => {:b => :c}}, {:a => {:b => Symbol}})
      end

      test('when format of an array') do
        formats_kernel([{:a => :b}], [{:a => Symbol}])
      end

    end

    tests('returns false') do

      test('when format of value does not match') do
        !formats_kernel({:a => :b}, {:a => String})
      end

      test('when not all keys are checked') do
        !formats_kernel({:a => :b}, {})
      end

      test('when some keys do not appear') do
        !formats_kernel({}, {:a => String})
      end

    end

  end

end

def model_tests(collection, params = {}, mocks_implemented = true)

  tests('success') do

    if !Fog.mocking? || mocks_implemented
      @instance = collection.new(params)
    end

    tests("#save").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      @instance.save
    end

    if block_given?
      yield
    end

    tests("#destroy").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      @instance.destroy
    end

  end

  tests('failure') do
  end

end

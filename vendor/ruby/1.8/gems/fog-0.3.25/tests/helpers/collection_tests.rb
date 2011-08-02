def collection_tests(collection, params = {}, mocks_implemented = true)

  tests('success') do

    tests("#new(#{params.inspect})").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      collection.new(params)
    end

    tests("#create(#{params.inspect})").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      @instance = collection.create(params)
    end

    tests("#all").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      collection.all
    end

    if !Fog.mocking? || mocks_implemented
      @identity = @instance.identity
    end

    tests("#get(#{@identity})").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      collection.get(@identity)
    end

    if block_given?
      yield
    end

    if !Fog.mocking? || mocks_implemented
      @instance.destroy
    end
  end

  tests('failure') do

    if !Fog.mocking? || mocks_implemented
      @identity = @identity.to_s.gsub(/\w/, '0')
    end

    tests("#get('#{@identity}')").returns(nil) do
      pending if Fog.mocking? && !mocks_implemented
      collection.get(@identity)
    end

  end

end

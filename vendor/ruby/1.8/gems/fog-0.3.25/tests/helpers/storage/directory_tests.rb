def directory_tests(connection, params = {}, mocks_implemented = true)

  params = {:key => 'fogdirectorytests'}.merge!(params)

  model_tests(connection.directories, params, mocks_implemented) do

    tests("#public=(true)").succeeds do
      pending if Fog.mocking? && !mocks_implemented
      @instance.public=(true)
    end

    if !Fog.mocking? || mocks_implemented
      responds_to(:public_url)
    end

  end

end

def server_tests(connection, params = {}, mocks_implemented = true)

  model_tests(connection.servers, params, mocks_implemented) do

    responds_to([:ready?, :state])

    tests('#reboot').succeeds do
      pending if Fog.mocking? && !mocks_implemented
      @instance.wait_for { ready? }
      @instance.reboot
    end

    if !Fog.mocking? || mocks_implemented
      @instance.wait_for { ready? }
    end

  end

end

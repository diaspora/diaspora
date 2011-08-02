def file_tests(connection, params = {}, mocks_implemented = true)

  params = {:key => 'fog_file_tests', :body => lorem_file, :public => true}.merge!(params)

  if !Fog.mocking? || mocks_implemented
    @directory = connection.directories.create(:key => 'fogfilestests')

    model_tests(@directory.files, params, mocks_implemented) do

      responds_to(:public_url)

      tests("#public=(true)").succeeds do
        pending if Fog.mocking? && !mocks_implemented
        @instance.public=(true)
      end

      test("@instance.public_url.nil? || Excon.get(@instance.public_url).body == lorem_file.read") do
        pending if Fog.mocking?
        @instance.public_url.nil? || Excon.get(@instance.public_url).body == lorem_file.read
      end

    end

    @directory.destroy
  end

end

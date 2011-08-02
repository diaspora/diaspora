def files_tests(connection, params = {}, mocks_implemented = true)

  params = {:key => 'fog_files_tests', :body => lorem_file}.merge!(params)

  if !Fog.mocking? || mocks_implemented
    @directory = connection.directories.create(:key => 'fogfilestests')

    collection_tests(@directory.files, params, mocks_implemented)

    @directory.destroy
  end

end

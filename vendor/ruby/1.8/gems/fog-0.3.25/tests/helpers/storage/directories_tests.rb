def directories_tests(connection, params = {}, mocks_implemented = true)

  params = {:key => 'fogdirectoriestests'}.merge!(params)

  collection_tests(connection.directories, params, mocks_implemented)

end

Shindo.tests('AWS::Compute | server model', ['aws']) do

  # image ami-1a837773 = Ubuntu
  server_tests(AWS[:compute], {:image_id => 'ami-1a837773'})

end

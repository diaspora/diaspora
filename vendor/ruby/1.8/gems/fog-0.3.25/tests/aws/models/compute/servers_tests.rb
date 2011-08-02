Shindo.tests('AWS::Compute | servers collection', ['aws']) do

  # image ami-1a837773 = Ubuntu
  servers_tests(AWS[:compute], {:image_id => 'ami-1a837773'})

end

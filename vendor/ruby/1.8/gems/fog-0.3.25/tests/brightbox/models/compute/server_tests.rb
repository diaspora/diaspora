Shindo.tests('Brightbox::Compute | server model', ['brightbox']) do

  # image img-t4p09 = Ubuntu Maverick 10.10 server
  server_tests(Brightbox[:compute], {:image_id => 'img-t4p09'}, false)

end

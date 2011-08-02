Shindo.tests('Brightbox::Compute | servers collection', ['brightbox']) do

  # image img-t4p09 = Ubuntu Maverick 10.10 server
  servers_tests(Brightbox[:compute], {:image_id => 'img-t4p09'}, false)

end

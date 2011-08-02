Shindo.tests('Rackspace::Compute | server model', ['rackspace']) do

  # image 49 = Ubuntu 10.04 LTS (lucid)
  server_tests(Rackspace[:compute], {:image_id => 49, :name => "fog_#{Time.now.to_i}"})

end

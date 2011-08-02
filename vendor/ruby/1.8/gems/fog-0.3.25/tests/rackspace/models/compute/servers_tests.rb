Shindo.tests('Rackspace::Compute | servers collection', ['rackspace']) do

  # image 49 = Ubuntu 10.04 LTS (lucid)
  servers_tests(Rackspace[:compute], {:image_id => 49, :name => "fog_#{Time.now.to_i}"})

end

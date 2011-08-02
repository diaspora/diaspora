Shindo.tests('Slicehost::Compute | servers collection', ['slicehost']) do

  # image 49 = Ubuntu 10.04 LTS (lucid)
  servers_tests(Slicehost[:compute], {:image_id => 49, :name => "fog_#{Time.now.to_i}"}, false)

end

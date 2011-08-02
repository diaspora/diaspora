Shindo.tests('Slicehost::Compute | server model', ['slicehost']) do

  # image 49 = Ubuntu 10.04 LTS (lucid)
  server_tests(Slicehost[:compute], {:image_id => 49, :name => "fog_#{Time.now.to_i}"}, false)

end

Shindo.tests('Rackspace::Compute | flavors collection', ['rackspace']) do

  flavors_tests(Rackspace[:compute], {}, false)

end

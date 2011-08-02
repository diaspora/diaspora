Shindo.tests('Bluebox::Compute | server model', ['bluebox']) do

  server_tests(Bluebox[:compute], {:image_id => 'a00baa8f-b5d0-4815-8238-b471c4c4bf72'}, false)

end

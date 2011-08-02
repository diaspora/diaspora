2010-03-16

RUNNING TESTS

Run the test suite from the net-ssh directory with the following command:

     ruby -Ilib -Itest -rrubygems test/test_all.rb

Run a single test file like this:

     ruby -Ilib -Itest -rrubygems test/transport/test_server_version.rb


EXPECTED RESULTS

* Ruby 1.8: all tests pass

* Ruby 1.9: all tests pass

* JRuby 1.4: 96% tests pass (242 tests, 554 assertions, 0 failures, 8 errors)


PORT FORWARDING TESTS

     ruby -Ilib -Itest -rrubygems test/manual/test_forward.rb

test_forward.rb must be run separately from the test suite because
it requires authorizing your public SSH keys on you localhost.

If you already have keys you can do this:

     cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

If you don't have keys see:

     http://kimmo.suominen.com/docs/ssh/#ssh-keygen

You should now be able to login to your localhost with out
bring prompted for a password:

     ssh localhost

-Delano

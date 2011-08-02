Show failing specs instantly. Show passing spec as green dots as usual.

Output
======
    ....................................................*....
    1) ApplicationController#sign_out_and_redirect with JSON should return JSON indicating success
       Failure/Error: json_response = JSON.parse response.body
       A JSON text must at least contain two octets!
       # /Users/miwillhite/.rvm/gems/ruby-1.9.2-p0/gems/json_pure-1.4.6/lib/json/common.rb:146:in `initialize'
       # /Users/miwillhite/.rvm/gems/ruby-1.9.2-p0/gems/json_pure-1.4.6/lib/json/common.rb:146:in `new'
       # /Users/miwillhite/.rvm/gems/ruby-1.9.2-p0/gems/json_pure-1.4.6/lib/json/common.rb:146:in `parse'
       # ./spec/controllers/application_controller_spec.rb:17:in `block (4 levels) in <top (required)>'
    ..................................................................

    Finished in 650.095614 seconds

    1680 examples, 1 failure, 1 pending



Install
=======
As Gem:
    gem install rspec-instafail

    # spec/spec.opts (.rspec for rspec 2)
    --require rspec/instafail
    --format RSpec::Instafail

As plugin:
    rails plugin install git://github.com/grosser/rspec-instafail.git

    # spec/spec.opts (.rspec for rspec 2)
    --require vendor/plugins/rspec-instafail/lib/rspec/instafail
    --format RSpec::Instafail

Authors
=======

### [Contributors](http://github.com/grosser/rspec-instafail/contributors)
 - [Matthew Willhite](http://github.com/miwillhite)
 - [Jeff Kreeftmeijer](http://jeffkreeftmeijer.com)
 - [Steve Tooke](http://tooky.github.com)
 - [Josh Ellithorpe](https://github.com/zquestz)
 - [Raphael Sofaer](https://github.com/rsofaer)
 - [Mike Mazur](https://github.com/mikem)

[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...

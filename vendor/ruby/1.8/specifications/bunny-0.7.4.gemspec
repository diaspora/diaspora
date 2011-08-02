# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bunny}
  s.version = "0.7.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Duncan", "Eric Lindvall", "Jakub Stastny aka botanicus", "Michael S. Klishin", "Stefan Kaes"]
  s.date = %q{2011-07-29}
  s.description = %q{A synchronous Ruby AMQP client that enables interaction with AMQP-compliant brokers.}
  s.email = ["celldee@gmail.com", "eric@5stops.com", "stastny@101ideas.cz", "michael@novemberain.com", "skaes@railsexpress.de"]
  s.extra_rdoc_files = ["README.textile"]
  s.files = [".gitignore", ".rspec", ".travis.yml", ".yardopts", "CHANGELOG", "Gemfile", "LICENSE", "README.textile", "Rakefile", "bunny.gemspec", "examples/simple_08.rb", "examples/simple_09.rb", "examples/simple_ack_08.rb", "examples/simple_ack_09.rb", "examples/simple_consumer_08.rb", "examples/simple_consumer_09.rb", "examples/simple_fanout_08.rb", "examples/simple_fanout_09.rb", "examples/simple_headers_08.rb", "examples/simple_headers_09.rb", "examples/simple_publisher_08.rb", "examples/simple_publisher_09.rb", "examples/simple_topic_08.rb", "examples/simple_topic_09.rb", "ext/amqp-0.8.json", "ext/amqp-0.9.1.json", "ext/config.yml", "ext/qparser.rb", "lib/bunny.rb", "lib/bunny/channel08.rb", "lib/bunny/channel09.rb", "lib/bunny/client08.rb", "lib/bunny/client09.rb", "lib/bunny/consumer.rb", "lib/bunny/exchange08.rb", "lib/bunny/exchange09.rb", "lib/bunny/queue08.rb", "lib/bunny/queue09.rb", "lib/bunny/subscription08.rb", "lib/bunny/subscription09.rb", "lib/bunny/version.rb", "lib/qrack/amq-client-url.rb", "lib/qrack/channel.rb", "lib/qrack/client.rb", "lib/qrack/errors.rb", "lib/qrack/protocol/protocol08.rb", "lib/qrack/protocol/protocol09.rb", "lib/qrack/protocol/spec08.rb", "lib/qrack/protocol/spec09.rb", "lib/qrack/qrack08.rb", "lib/qrack/qrack09.rb", "lib/qrack/queue.rb", "lib/qrack/subscription.rb", "lib/qrack/transport/buffer08.rb", "lib/qrack/transport/buffer09.rb", "lib/qrack/transport/frame08.rb", "lib/qrack/transport/frame09.rb", "spec/spec_08/bunny_spec.rb", "spec/spec_08/connection_spec.rb", "spec/spec_08/exchange_spec.rb", "spec/spec_08/queue_spec.rb", "spec/spec_09/amqp_url_spec.rb", "spec/spec_09/bunny_spec.rb", "spec/spec_09/connection_spec.rb", "spec/spec_09/exchange_spec.rb", "spec/spec_09/queue_spec.rb"]
  s.homepage = %q{http://github.com/ruby-amqp/bunny}
  s.post_install_message = %q{[[32mVersion 0.7.3[0m] AMQP connection URI parser now respects port
}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{bunny-amqp}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Synchronous Ruby AMQP 0.9.1 client}
  s.test_files = ["spec/spec_08/bunny_spec.rb", "spec/spec_08/connection_spec.rb", "spec/spec_08/exchange_spec.rb", "spec/spec_08/queue_spec.rb", "spec/spec_09/amqp_url_spec.rb", "spec/spec_09/bunny_spec.rb", "spec/spec_09/connection_spec.rb", "spec/spec_09/exchange_spec.rb", "spec/spec_09/queue_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

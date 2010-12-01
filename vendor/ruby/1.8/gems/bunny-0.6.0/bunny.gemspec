Gem::Specification.new do |s|
  s.name = %q{bunny}
  s.version = "0.6.0"
  s.authors = ["Chris Duncan"]
  s.date = %q{2009-10-05}
  s.description = %q{Another synchronous Ruby AMQP client}
  s.email = %q{celldee@gmail.com}
  s.rubyforge_project = %q{bunny-amqp}
  s.has_rdoc = true
 	s.extra_rdoc_files = [ "README.rdoc" ]
  s.rdoc_options = [ "--main", "README.rdoc" ]
  s.homepage = %q{http://github.com/celldee/bunny/tree/master}
  s.summary = %q{A synchronous Ruby AMQP client that enables interaction with AMQP-compliant brokers/servers.}
  s.files = ["LICENSE",
	 	"README.rdoc",
		"Rakefile",
		"bunny.gemspec",
		"examples/simple_08.rb",
		"examples/simple_ack_08.rb",
		"examples/simple_consumer_08.rb",
		"examples/simple_fanout_08.rb",
		"examples/simple_publisher_08.rb",
		"examples/simple_topic_08.rb",
		"examples/simple_headers_08.rb",
		"examples/simple_09.rb",
		"examples/simple_ack_09.rb",
		"examples/simple_consumer_09.rb",
		"examples/simple_fanout_09.rb",
		"examples/simple_publisher_09.rb",
		"examples/simple_topic_09.rb",
		"examples/simple_headers_09.rb",
		"lib/bunny.rb",
		"lib/bunny/channel08.rb",
		"lib/bunny/channel09.rb",
		"lib/bunny/client08.rb",
		"lib/bunny/client09.rb",
		"lib/bunny/exchange08.rb",
		"lib/bunny/exchange09.rb",
		"lib/bunny/queue08.rb",
		"lib/bunny/queue09.rb",
		"lib/bunny/subscription08.rb",
		"lib/bunny/subscription09.rb",
		"lib/qrack/client.rb",
		"lib/qrack/channel.rb",
		"lib/qrack/queue.rb",
		"lib/qrack/subscription.rb",
		"lib/qrack/protocol/protocol08.rb",
		"lib/qrack/protocol/protocol09.rb",
		"lib/qrack/protocol/spec08.rb",
		"lib/qrack/protocol/spec09.rb",
		"lib/qrack/qrack08.rb",
		"lib/qrack/qrack09.rb",
		"lib/qrack/transport/buffer08.rb",
		"lib/qrack/transport/buffer09.rb",
		"lib/qrack/transport/frame08.rb",
		"lib/qrack/transport/frame09.rb",
		"spec/spec_08/bunny_spec.rb",
		"spec/spec_08/exchange_spec.rb",
		"spec/spec_08/queue_spec.rb",
		"spec/spec_08/connection_spec.rb",
		"spec/spec_09/bunny_spec.rb",
		"spec/spec_09/exchange_spec.rb",
		"spec/spec_09/queue_spec.rb",
		"spec/spec_09/connection_spec.rb"]
end
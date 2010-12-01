# bunny_spec.rb

# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

# If this is not the case, please change the 'Bunny.new' call below to include
# the relevant arguments e.g. @b = Bunny.new(:user => 'john', :pass => 'doe', :host => 'foobar')

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. lib bunny]))

describe Bunny do
	
	before(:each) do
    @b = Bunny.new(:spec => '09')
		@b.start
	end
	
  it "should connect to an AMQP server" do
    @b.status.should == :connected
  end

	it "should be able to create and open a new channel" do
		c = @b.create_channel
		c.number.should == 2
		c.should be_an_instance_of(Bunny::Channel09)
		@b.channels.size.should == 3
		c.open.should == :open_ok
		@b.channel.number.should == 2 
	end
	
	it "should be able to switch between channels" do
		@b.channel.number.should == 1
		@b.switch_channel(0)
		@b.channel.number.should == 0
	end
	
	it "should raise an error if trying to switch to a non-existent channel" do
		lambda { @b.switch_channel(5) }.should raise_error(RuntimeError)
	end

	it "should be able to create an exchange" do
		exch = @b.exchange('test_exchange')
		exch.should be_an_instance_of(Bunny::Exchange09)
		exch.name.should == 'test_exchange'
		@b.exchanges.has_key?('test_exchange').should be(true)
	end

	it "should be able to create a queue" do
		q = @b.queue('test1')
		q.should be_an_instance_of(Bunny::Queue09)
		q.name.should == 'test1'
		@b.queues.has_key?('test1').should be(true)
  end

	# Current RabbitMQ has not implemented some functionality
	it "should raise an error if setting of QoS fails" do
		lambda { @b.qos(:global => true) }.should raise_error(Bunny::ForcedConnectionCloseError)
		@b.status.should == :not_connected
	end

	it "should be able to set QoS" do
		@b.qos.should == :qos_ok
	end

end
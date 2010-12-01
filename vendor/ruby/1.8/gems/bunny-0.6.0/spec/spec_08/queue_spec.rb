# queue_spec.rb

# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

# If this is not the case, please change the 'Bunny.new' call below to include
# the relevant arguments e.g. @b = Bunny.new(:user => 'john', :pass => 'doe', :host => 'foobar')

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. lib bunny]))

describe 'Queue' do
	
	before(:each) do
    @b = Bunny.new
		@b.start
	end
	
	it "should ignore the :nowait option when instantiated" do
		q = @b.queue('test0', :nowait => true)
	end
	
	it "should ignore the :nowait option when binding to an exchange" do
		exch = @b.exchange('direct_exch')
		q = @b.queue('test0')
		q.bind(exch, :nowait => true).should == :bind_ok
	end
	
	it "should raise an error when trying to bind to a non-existent exchange" do
		q = @b.queue('test1')
		lambda {q.bind('bogus')}.should raise_error(Bunny::ForcedChannelCloseError)
		@b.channel.active.should == false
	end
	
	it "should be able to bind to an existing exchange" do
		exch = @b.exchange('direct_exch')
		q = @b.queue('test1')
		q.bind(exch).should == :bind_ok
	end
	
	it "should ignore the :nowait option when unbinding from an exchange" do
		exch = @b.exchange('direct_exch')
		q = @b.queue('test0')
		q.unbind(exch, :nowait => true).should == :unbind_ok
	end
	
	it "should raise an error if unbinding from a non-existent exchange" do
		q = @b.queue('test1')
		lambda {q.unbind('bogus')}.should raise_error(Bunny::ForcedChannelCloseError)
		@b.channel.active.should == false
	end
	
	it "should be able to unbind from an existing exchange" do
		exch = @b.exchange('direct_exch')
		q = @b.queue('test1')
		q.unbind(exch).should == :unbind_ok
	end

	it "should be able to publish a message" do
		q = @b.queue('test1')
		q.publish('This is a test message')
		q.message_count.should == 1
	end
	
	it "should be able to pop a message complete with header and delivery details" do
		q = @b.queue('test1')
		msg = q.pop()
		msg.should be_an_instance_of(Hash)
		msg[:header].should be_an_instance_of(Bunny::Protocol::Header)
		msg[:payload].should == 'This is a test message'
		msg[:delivery_details].should be_an_instance_of(Hash)
		q.message_count.should == 0
	end

	it "should be able to pop a message and just get the payload" do
		q = @b.queue('test1')
		q.publish('This is another test message')
		msg = q.pop[:payload]
		msg.should == 'This is another test message'
		q.message_count.should == 0
	end
	
	it "should be able to pop a message where body length exceeds max frame size" do
		q = @b.queue('test1')
		lg_msg = 'z' * 142000
		q.publish(lg_msg)
		msg = q.pop[:payload]
		msg.should == lg_msg
	end
	
	it "should be able call a block when popping a message" do
		q = @b.queue('test1')
		q.publish('This is another test message')
		q.pop { |msg| msg[:payload].should == 'This is another test message' }
		q.pop { |msg| msg[:payload].should == :queue_empty }
	end
	
	it "should raise an error if purge fails" do
		q = @b.queue('test1')
		5.times {q.publish('This is another test message')}
		q.message_count.should == 5
		lambda {q.purge(:queue => 'bogus')}.should raise_error(Bunny::ForcedChannelCloseError)
	end
	
	it "should be able to be purged to remove all of its messages" do
		q = @b.queue('test1')
		q.message_count.should == 5
		q.purge.should == :purge_ok
		q.message_count.should == 0
	end
	
	it "should return an empty message when popping an empty queue" do
		q = @b.queue('test1')
		q.publish('This is another test message')
		q.pop
		msg = q.pop[:payload]
		msg.should == :queue_empty
	end
	
	it "should stop subscription without processing messages if max specified is 0" do
		q = @b.queue('test1')
		5.times {q.publish('Yet another test message')}
		q.message_count.should == 5
		q.subscribe(:message_max => 0)
		q.message_count.should == 5
		q.purge.should == :purge_ok
	end
	
	it "should stop subscription after processing number of messages specified > 0" do
		q = @b.queue('test1')
		5.times {q.publish('Yet another test message')}
		q.message_count.should == 5
		q.subscribe(:message_max => 5)
	end

	it "should stop subscription after processing message_max messages < total in queue" do
		q = @b.queue('test1')
		@b.qos()
		10.times {q.publish('Yet another test message')}
		q.message_count.should == 10
		q.subscribe(:message_max => 5, :ack => true)
		q.message_count.should == 5
		q.purge.should == :purge_ok
	end

	it "should raise an error when delete fails" do
		q = @b.queue('test1')
		lambda {q.delete(:queue => 'bogus')}.should raise_error(Bunny::ForcedChannelCloseError)
		@b.channel.active.should == false
	end

  it "should pass correct block parameters through on subscribe" do
    q = @b.queue('test1')
    q.publish("messages pop\'n")

    q.subscribe do |msg|
      msg[:header].should be_an_instance_of Qrack::Protocol::Header
      msg[:payload].should == "messages pop'n"
      msg[:delivery_details].should_not be_nil

      q.unsubscribe
			break
    end

  end

  it "should finish processing subscription messages if break is called in block" do
    q = @b.queue('test1')
    q.publish('messages in my quezen')

    q.subscribe do |msg|
      msg[:payload].should == 'messages in my quezen'
      q.unsubscribe
			break
    end

    5.times {|i| q.publish("#{i}")}
		q.subscribe do |msg|
		  if msg[:payload] == '4'
				q.unsubscribe 
				break
			end
		end

  end

	it "should be able to be deleted" do
		q = @b.queue('test1')
		res = q.delete
		res.should == :delete_ok
		@b.queues.has_key?('test1').should be(false)
	end
	
	it "should ignore the :nowait option when deleted" do
		q = @b.queue('test0')
		q.delete(:nowait => true)
	end

  it "should support server named queues" do
    q = @b.queue
    q.name.should_not == nil

    @b.queue(q.name).should == q
    q.delete
  end
	
end

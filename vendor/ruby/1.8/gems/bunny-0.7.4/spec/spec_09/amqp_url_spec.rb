# encoding: utf-8

# Assumes that target message broker/server has a user called 'guest' with a password 'guest'
# and that it is running on 'localhost'.

# If this is not the case, please change the 'Bunny.new' call below to include
# the relevant arguments e.g. @b = Bunny.new(:user => 'john', :pass => 'doe', :host => 'foobar')

require "bunny"

describe Bunny do
  context "AMQP URL parsing" do
    it "handles port properly" do
      bunny = Bunny.new("amqp://dev.rabbitmq.com:1212")
      bunny.port.should eql(1212)
    end
  end
end

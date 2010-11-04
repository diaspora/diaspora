require File.dirname(__FILE__) + '/../config/environment'
Magent::Processor.new(Magent::AsyncChannel.new(:default)).run!

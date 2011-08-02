shared_examples_for "an oauth strategy" do
  it 'should be initializable with only three arguments' do
    lambda{ strategy_class.new(lambda{|env| [200, {}, ['Hello World']]}, 'key', 'secret') }.should_not raise_error
  end

  it 'should be initializable with a block' do
    lambda{ strategy_class.new(lambda{|env| [200, {}, ['Hello World']]}){|s| s.consumer_key = 'abc'} }.should_not raise_error
  end

  it 'should handle the setting of client options' do
    s = strategy_class.new(lambda{|env| [200, {}, ['Hello World']]}, 'key', 'secret', :client_options => {:abc => 'def'})
    s.consumer.options[:abc].should == 'def'
  end
end

shared_examples_for "an oauth2 strategy" do
  it 'should be initializable with only three arguments' do
    lambda{ strategy_class.new(lambda{|env| [200, {}, ['Hello World']]}, 'key', 'secret') }.should_not raise_error
  end

  it 'should be initializable with a block' do
    lambda{ strategy_class.new(lambda{|env| [200, {}, ['Hello World']]}){|s| s.client_id = 'abc'} }.should_not raise_error
  end

  it 'should handle the setting of client options' do
    s = strategy_class.new(lambda{|env| [200, {}, ['Hello World']]}, 'key', 'secret', :client_options => {:abc => 'def'})
    s.client.options[:abc].should == 'def'
  end
end

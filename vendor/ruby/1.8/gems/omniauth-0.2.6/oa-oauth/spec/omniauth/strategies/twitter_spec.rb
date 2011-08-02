require File.expand_path('../../../spec_helper', __FILE__)

describe OmniAuth::Strategies::Twitter do
  it_should_behave_like 'an oauth strategy'

  it 'should use the authenticate (sign in) path by default' do
    s = strategy_class.new(app, 'abc', 'def')
    s.consumer.options[:authorize_path].should == '/oauth/authenticate'
  end

	it 'should set options[:authorize_params] to { :force_login => "true" } if :force_login is true' do
		s = strategy_class.new(app, 'abc', 'def', :force_login => true)
		s.options[:authorize_params].should == { :force_login => 'true' }
	end

  it 'should use the authorize path if :sign_in is false' do
    s = strategy_class.new(app, 'abc', 'def', :sign_in => false)
    s.consumer.options[:authorize_path].should == '/oauth/authorize'
  end
end

require File.dirname(__FILE__) + "/spec_helper"

describe "YARD::Server::RackMiddleware" do
  before do
    begin; require 'rack'; rescue LoadError; pending "rack required for these tests" end
    @superapp = mock(:superapp)
    @app = YARD::Server::RackMiddleware.new(@superapp, :libraries => {'foo' => [LibraryVersion.new('foo', nil)]})
  end
  
  it "should handle requests" do
    @app.call(Rack::MockRequest.env_for('/'))[0].should == 200
  end
  
  it "should pass up to the next middleware on 404" do
    @superapp.should_receive(:call).and_return([200, {}, ['OK']])
    @app.call(Rack::MockRequest.env_for('/INVALID')).should == [200, {}, ['OK']]
  end
end
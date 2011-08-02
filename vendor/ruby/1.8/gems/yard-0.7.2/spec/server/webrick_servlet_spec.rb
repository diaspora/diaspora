require File.dirname(__FILE__) + '/spec_helper'

describe YARD::Server::WebrickServlet do
  describe '#do_GET' do
    it "should perform a GET" do
      resp = OpenStruct.new
      class << resp
        def []=(name, value) (self.headers ||= {})[name] = value end
      end
      server = mock(:server)
      server.stub!(:[])
      adapter = mock_adapter
      adapter.router = proc { [200, {'Header' => 'foo'}, ['body']]}
      WebrickServlet.new(server, adapter).do_GET(mock_request('/foo'), resp)
      resp.status.should == 200
      resp.headers.should == {'Header' => 'foo'}
      resp.body.should == 'body'
    end
  end
end
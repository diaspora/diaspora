require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Capybara::Server do

  it "should spool up a rack server" do
    @app = proc { |env| [200, {}, "Hello Server!"]}
    @server = Capybara::Server.new(@app).boot
    
    @res = Net::HTTP.start(@server.host, @server.port) { |http| http.get('/') }
    
    @res.body.should include('Hello Server')
  end

  it "should do nothing when no server given" do
    running do
      @server = Capybara::Server.new(nil).boot
    end.should_not raise_error
  end
  
  it "should find an available port" do
    @app1 = proc { |env| [200, {}, "Hello Server!"]}
    @app2 = proc { |env| [200, {}, "Hello Second Server!"]}

    @server1 = Capybara::Server.new(@app1).boot
    @server2 = Capybara::Server.new(@app2).boot
    
    @res1 = Net::HTTP.start(@server1.host, @server1.port) { |http| http.get('/') }
    @res1.body.should include('Hello Server')
    
    @res2 = Net::HTTP.start(@server2.host, @server2.port) { |http| http.get('/') }
    @res2.body.should include('Hello Second Server')
  end
  
  it "should use the server if it already running" do
    @app1 = proc { |env| [200, {}, "Hello Server!"]}
    @app2 = proc { |env| [200, {}, "Hello Second Server!"]}

    @server1a = Capybara::Server.new(@app1).boot
    @server1b = Capybara::Server.new(@app1).boot
    @server2a = Capybara::Server.new(@app2).boot
    @server2b = Capybara::Server.new(@app2).boot
    
    @res1 = Net::HTTP.start(@server1b.host, @server1b.port) { |http| http.get('/') }
    @res1.body.should include('Hello Server')
    
    @res2 = Net::HTTP.start(@server2b.host, @server2b.port) { |http| http.get('/') }
    @res2.body.should include('Hello Second Server')
    
    @server1a.port.should == @server1b.port
    @server2a.port.should == @server2b.port
  end

end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Culerity do
  describe 'run_rails' do
    def stub_rails_root!
      unless defined?(::Rails)
        Kernel.const_set "Rails", stub()
      end
      Rails.stub!(:root).and_return(Dir.pwd)
    end
    
    before(:each) do
      Kernel.stub!(:sleep)
      IO.stub!(:popen)
      Culerity.stub!(:fork).and_yield.and_return(3200)
      Culerity.stub!(:exec)
      Culerity.stub!(:sleep)
      [$stdin, $stdout, $stderr].each{|io| io.stub(:reopen)}
    end
    
    it "should not run rails if we are not using rails" do
      Culerity.should_not_receive(:exec)
      Culerity.run_rails :port => 4000, :environment => 'culerity'
    end
    
    describe "when Rails is being used" do
      before(:each) do
        stub_rails_root!
      end
      
      it "should run rails with default values" do
        Culerity.should_receive(:exec).with("script/server -e culerity -p 3001")
        Culerity.run_rails
      end
      
      it "should run rails with the given values" do
        Culerity.should_receive(:exec).with("script/server -e culerity -p 4000")
        Culerity.run_rails :port => 4000, :environment => 'culerity'
      end
      
      it "should change into the rails root directory" do
        Dir.should_receive(:chdir).with(Dir.pwd)
        Culerity.run_rails :port => 4000, :environment => 'culerity'
      end
      
      it "should wait for the server to start up" do
        Culerity.should_receive(:sleep)
        Culerity.run_rails :port => 4000, :environment => 'culerity'
      end
      
      it "should reopen the i/o channels to /dev/null" do
        [$stdin, $stdout, $stderr].each{|io| io.should_receive(:reopen).with("/dev/null")}
        Culerity.run_rails :port => 4000, :environment => 'culerity'
      end
    end
  end
  
  describe "run_server" do
    before(:each) do
      IO.stub!(:popen)
    end
    
    after(:each) do
      Culerity.jruby_invocation = nil
    end
    
    it "knows where it is located" do
      Culerity.culerity_root.should == File.expand_path(File.dirname(__FILE__) + '/../')
    end
    
    it "has access to the Celerity invocation" do
      Culerity.stub!(:culerity_root).and_return('/path/to/culerity')
      
      Culerity.celerity_invocation.should == "/path/to/culerity/lib/start_celerity.rb"
    end
    
    describe "invoking JRuby" do
      it "knows how to invoke it" do
        Culerity.jruby_invocation.should == 'jruby'
      end
      
      it "allows for the invocation to be overridden directly" do
        Culerity.jruby_invocation = '/opt/local/bin/jruby'
        
        Culerity.jruby_invocation.should == '/opt/local/bin/jruby'
      end
      
      it "allows for the invocation to be overridden from an environment variable" do
        ENV['JRUBY_INVOCATION'] = 'rvm jruby ruby'
        
        Culerity.jruby_invocation.should == 'rvm jruby ruby'
      end
    end
    
    it "shells out and sparks up jruby with the correct invocation" do
      Culerity.stub!(:celerity_invocation).and_return('/path/to/start_celerity.rb')
      
      IO.should_receive(:popen).with('jruby "/path/to/start_celerity.rb"', 'r+')
      
      Culerity.run_server
    end
    
    it "allows a more complex situation, e.g. using RVM + named gemset" do
      Culerity.stub!(:celerity_invocation).and_return('/path/to/start_celerity.rb')
      
      IO.should_receive(:popen).with('rvm jruby@culerity ruby "/path/to/start_celerity.rb"', 'r+')
      
      Culerity.jruby_invocation = "rvm jruby@culerity ruby"
      Culerity.run_server
    end
  end
end
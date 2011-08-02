require File.join('.', File.dirname(__FILE__), 'test_helper.rb')

Vegas::Runner.class_eval do
  remove_const :ROOT_DIR
  ROOT_DIR = File.join(File.dirname(__FILE__), 'tmp', '.vegas')
end

describe 'Vegas::Runner' do
  before do
    FileUtils.rm_rf(File.join(File.dirname(__FILE__), 'tmp'))
    @log = StringIO.new
    Vegas::Runner.logger = Logger.new(@log)
  end

  describe 'creating an instance' do

    describe 'basic usage' do
      before do
        Vegas::Runner.any_instance.expects(:system).once
        vegas(TestApp1, 'vegas_test_app_1', {:sessions => true}, ["route","--debug"])
      end

      it "sets app" do
        @vegas.app.should == TestApp1
      end

      it "sets app name" do
        @vegas.app_name.should == 'vegas_test_app_1'
      end

      it "sets quoted app name" do
        @vegas.quoted_app_name.should == "'vegas_test_app_1'"
      end

      it "sets filesystem friendly app name" do
        @vegas.filesystem_friendly_app_name.should == 'vegas_test_app_1'
      end

      it "stores options" do
        @vegas.options[:sessions].should.be.true
      end

      it "puts unparsed args into args" do
        @vegas.args.should == ["route"]
      end

      it "parses options into @options" do
        @vegas.options[:debug].should.be.true
      end

      it "writes the app dir" do
        @vegas.app_dir.should exist_as_file
      end

      it "writes a url with the port" do
        @vegas.url_file.should have_matching_file_content(/0.0.0.0\:#{@vegas.port}/)
      end

      it "knows where to find the pid file" do
        @vegas.pid_file.should.equal \
          File.join(@vegas.app_dir, @vegas.filesystem_friendly_app_name + ".pid")
        # @vegas.pid_file.should exist_as_file
      end
    end

    describe 'basic usage with a funky app name' do
      before do
        Vegas::Runner.any_instance.expects(:system).once
        vegas(TestApp1, 'Funky YEAH!1!', {:sessions => true}, ["route","--debug"])
      end

      it "sets app" do
        @vegas.app.should == TestApp1
      end

      it "sets app name" do
        @vegas.app_name.should == 'Funky YEAH!1!'
      end

      it "sets quoted app name" do
        @vegas.quoted_app_name.should == "'Funky YEAH!1!'"
      end

      it "sets filesystem friendly app name" do
        @vegas.filesystem_friendly_app_name.should == 'Funky_YEAH_1_'
      end

      it "stores options" do
        @vegas.options[:sessions].should.be.true
      end

      it "puts unparsed args into args" do
        @vegas.args.should == ["route"]
      end

      it "parses options into @options" do
        @vegas.options[:debug].should.be.true
      end

      it "writes the app dir" do
        @vegas.app_dir.should exist_as_file
      end

      it "writes a url with the port" do
        @vegas.url_file.should have_matching_file_content(/0.0.0.0\:#{@vegas.port}/)
      end

      it "knows where to find the pid file" do
        @vegas.pid_file.should.equal \
          File.join(@vegas.app_dir, @vegas.filesystem_friendly_app_name + ".pid")
        # @vegas.pid_file.should exist_as_file
      end
    end

    describe 'with a sinatra app using an explicit server setting' do
      before do
        TestApp1.set :server, "webrick"
        Vegas::Runner.any_instance.expects(:system).once
        Rack::Handler::WEBrick.stubs(:run)
        vegas(TestApp1, 'vegas_test_app_1', {:skip_launch => true, :sessions => true}, ["route","--debug"])
      end

      it 'sets the rack handler automaticaly' do
        @vegas.rack_handler.should == Rack::Handler::WEBrick
      end
    end

    describe 'with a simple rack app' do
      before do
        vegas(RackApp1, 'rack_app_1', {:skip_launch => true, :sessions => true})
      end

      it "sets default rack handler to thin" do
        @vegas.rack_handler.should == Rack::Handler::Thin
      end
    end

    describe 'with a launch path specified as a proc' do
      it 'evaluates the proc in the context of the runner' do
        Vegas::Runner.any_instance.expects(:system).once.with {|s| s =~ /\?search\=blah$/ }
        vegas(TestApp2,
              'vegas_test_app_2',
              {:launch_path => Proc.new {|r| "?search=#{r.args.first}" }},
              ["--debug", "blah"])
        @vegas.options[:launch_path].should.be instance_of(Proc)
      end
    end

    describe 'with a launch path specified as string' do
      it 'launches to the specific path' do
        Vegas::Runner.any_instance.expects(:system).once.with {|s| s =~ /\?search\=blah$/ }
        vegas(TestApp2,
              'vegas_test_app_2',
              {:launch_path => "?search=blah"},
              ["--debug", "blah"])
        @vegas.options[:launch_path].should == "?search=blah"
      end
    end


  end

end

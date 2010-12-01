require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


module Cucumber
  module Cli
    describe DRbClient do
      before(:each) do
        @args = ['features']
        @error_stream = StringIO.new
        @out_stream = StringIO.new

        @drb_object = mock('DRbObject', :run => true)
        DRbObject.stub!(:new_with_uri).and_return(@drb_object)
      end

      it "starts up a druby service" do
        DRb.should_receive(:start_service).with("druby://localhost:0")
        DRbClient.run(@args, @error_stream, @out_stream)
      end

      it "connects to the DRb server" do
        DRbObject.should_receive(:new_with_uri).with("druby://127.0.0.1:8990")
        DRbClient.run(@args, @error_stream, @out_stream)
      end

      it "runs the features on the DRb server" do
        @drb_object.should_receive(:run).with(@args, @error_stream, @out_stream)
        DRbClient.run(@args, @error_stream, @out_stream)
      end

      it "returns raises an error when it can't connect to the server" do
        DRbObject.stub!(:new_with_uri).and_raise(DRb::DRbConnError)
        lambda { DRbClient.run(@args, @error_stream, @out_stream) }.should raise_error(DRbClientError, "No DRb server is running.")
      end

      it "returns the result from the DRb server call" do
        @drb_object.should_receive(:run).and_return('foo')
        DRbClient.run(@args, @error_stream, @out_stream).should == 'foo'
      end

      context "with $CUCUMBER_DRB set" do
        before do 
          @original_env = ENV['CUCUMBER_DRB']
          ENV['CUCUMBER_DRB'] = '90000'
        end
        after do
          ENV['CUCUMBER_DRB'] = @original_env
        end
        it "connects to specified DRb server" do
          DRbObject.should_receive(:new_with_uri).with("druby://127.0.0.1:90000")
          DRbClient.run(@args, @error_stream, @out_stream)
        end
      end

      context "with provided drb_port" do
        before do
          @args = @args + ['--port', '8000']
        end
        it "connects to specified drb port" do
          DRbObject.should_receive(:new_with_uri).with("druby://127.0.0.1:8000")
          DRbClient.run(@args, @error_stream, @out_stream, 8000)
        end
        it "prefers configuration to environment"  do
          original = ENV['CUCUMBER_DRB'] = original
          begin
            ENV['CUCUMBER_DRB'] = "4000"
            DRbObject.should_receive(:new_with_uri).with("druby://127.0.0.1:8000")
            DRbClient.run(@args, @error_stream, @out_stream, 8000)
          ensure
            ENV['CUCUMBER_DRB'] = original
          end
        end
      end

    end
  end
end

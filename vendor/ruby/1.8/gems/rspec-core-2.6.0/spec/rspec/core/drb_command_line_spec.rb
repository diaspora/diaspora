require "spec_helper"

describe "::DRbCommandLine", :ruby => "!jruby" do
  let(:config) { RSpec::Core::Configuration.new }
  let(:out)    { StringIO.new }
  let(:err)    { StringIO.new }

  include_context "spec files"

  def command_line(args)
    RSpec::Core::DRbCommandLine.new(config_options(args))
  end

  def config_options(argv=[])
    options = RSpec::Core::ConfigurationOptions.new(argv)
    options.parse_options
    options
  end

  def run_with(args)
    command_line(args).run(err, out)
  end

  context "without server running" do
    it "raises an error" do
      lambda { run_with [] }.should raise_error(DRb::DRbConnError)
    end
  end

  describe "--drb-port" do
    def with_RSPEC_DRB_set_to(val)
      original = ENV['RSPEC_DRB']
      ENV['RSPEC_DRB'] = val
      begin
        yield
      ensure
        ENV['RSPEC_DRB'] = original
      end
    end

    context "without RSPEC_DRB environment variable set" do
      it "defaults to 8989" do
        with_RSPEC_DRB_set_to(nil) do
          command_line([]).drb_port.should == 8989
        end
      end

      it "sets the DRb port" do
        with_RSPEC_DRB_set_to(nil) do
          command_line(["--drb-port", "1234"]).drb_port.should == 1234
          command_line(["--drb-port", "5678"]).drb_port.should == 5678
        end
      end
    end

    context "with RSPEC_DRB environment variable set" do

      context "without config variable set" do
        it "uses RSPEC_DRB value" do
          with_RSPEC_DRB_set_to('9000') do
            command_line([]).drb_port.should == "9000"
          end
        end
      end

      context "and config variable set" do
        it "uses configured value" do
          with_RSPEC_DRB_set_to('9000') do
            command_line(%w[--drb-port 5678]).drb_port.should == 5678
          end
        end
      end
    end
  end

  context "with server running" do
    class ::FakeDrbSpecServer
      def self.run(argv, err, out)
        options = RSpec::Core::ConfigurationOptions.new(argv)
        options.parse_options
        RSpec::Core::CommandLine.new(options, RSpec::Core::Configuration.new).run(err, out)
      end
    end

    before(:all) do
      @drb_port = 8990
      @drb_example_file_counter = 0
      DRb::start_service("druby://127.0.0.1:#{@drb_port}", ::FakeDrbSpecServer)
    end

    after(:all) do
      DRb::stop_service
    end

    it "returns 0 if spec passes" do
      err, out = StringIO.new, StringIO.new
      result = command_line(["--drb-port", @drb_port.to_s, passing_spec_filename]).run(err, out)
      result.should be(0)
    end

    it "returns 1 if spec passes" do
      err, out = StringIO.new, StringIO.new
      result = command_line(["--drb-port", @drb_port.to_s, failing_spec_filename]).run(err, out)
      result.should be(1)
    end

    def run_spec_via_druby
      run_with([failing_spec_filename, "--colour", "--drb-port", @drb_port.to_s])
      out.rewind
      out.read
    end

    it "outputs green colorized text when running with --colour option" do
      pending "figure out a way to properly sandbox this"
      run_spec_via_druby.should =~ /\e\[32m/m
    end

    it "outputs red colorized text when running with -c option" do
      pending "figure out a way to properly sandbox this"
      run_spec_via_druby.should =~ /\e\[31m/m
    end
  end

end

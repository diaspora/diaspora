require 'spec_helper'

module RSpec::Core
  describe Runner do
    describe 'at_exit' do
      it 'sets an at_exit hook if none is already set' do
        RSpec::Core::Runner.stub(:installed_at_exit?).and_return(false)
        RSpec::Core::Runner.stub(:running_in_drb?).and_return(false)
        RSpec::Core::Runner.stub(:at_exit_hook_disabled?).and_return(false)
        RSpec::Core::Runner.should_receive(:at_exit)
        RSpec::Core::Runner.autorun
      end

      it 'does not set the at_exit hook if it is already set' do
        RSpec::Core::Runner.stub(:installed_at_exit?).and_return(true)
        RSpec::Core::Runner.stub(:running_in_drb?).and_return(false)
        RSpec::Core::Runner.stub(:at_exit_hook_disabled?).and_return(false)
        RSpec::Core::Runner.should_receive(:at_exit).never
        RSpec::Core::Runner.autorun
      end
    end

    describe "#run" do
      let(:err) { StringIO.new }
      let(:out) { StringIO.new }

      it "resets world and configuration" do
        RSpec.configuration.should_receive(:reset)
        RSpec.world.should_receive(:reset)
        RSpec::Core::Runner.run([], err, out)
      end

      context "with --drb or -X" do

        before(:each) do
          @options = RSpec::Core::ConfigurationOptions.new(%w[--drb --drb-port 8181 --color])
          RSpec::Core::ConfigurationOptions.stub(:new) { @options }
        end

        def run_specs
          RSpec::Core::Runner.run(%w[ --drb ], err, out)
        end

        context 'and a DRb server is running' do
          it "builds a DRbCommandLine and runs the specs" do
            drb_proxy = double(RSpec::Core::DRbCommandLine, :run => true)
            drb_proxy.should_receive(:run).with(err, out)

            RSpec::Core::DRbCommandLine.should_receive(:new).and_return(drb_proxy)

            run_specs
          end
        end

        context 'and a DRb server is not running' do
          before(:each) do
            RSpec::Core::DRbCommandLine.should_receive(:new).and_raise(DRb::DRbConnError)
          end

          it "outputs a message" do
            err.should_receive(:puts).with(
              "No DRb server is running. Running in local process instead ..."
            )
            run_specs
          end

          it "builds a CommandLine and runs the specs" do
            process_proxy = double(RSpec::Core::CommandLine, :run => true)
            process_proxy.should_receive(:run).with(err, out)

            RSpec::Core::CommandLine.should_receive(:new).and_return(process_proxy)

            run_specs
          end
        end
      end
    end
  end
end

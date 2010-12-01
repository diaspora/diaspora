require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'cucumber/wire_support/wire_language'
require 'tempfile'

module Cucumber
  module WireSupport
    describe Configuration do
      let(:wire_file) { Tempfile.new('wire') }
      let(:config) { Configuration.new(wire_file.path) }
      
      def write_wire_file(contents)
        wire_file << contents
        wire_file.close
      end
      
      it "reads the hostname / port from the file" do
        write_wire_file %q{
          host: localhost
          port: 54321
        }
        config.host.should == 'localhost'
        config.port.should == 54321
      end
      
      it "reads the timeout for a specific message" do
        write_wire_file %q{
          host: localhost
          port: 54321
          timeout:
            invoke: 99
        }
        config.timeout('invoke').should == 99
      end
      
      describe "a wire file with no timeouts specified" do
        before(:each) do
          write_wire_file %q{
            host: localhost
            port: 54321
          }
        end
        
        %w(invoke begin_scenario end_scenario).each do |message|
          it "sets the default timeout for '#{message}' to 120 seconds" do
            config.timeout(message).should == 120
          end
        end
      end
    end
  end
end
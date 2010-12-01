require File.expand_path(File.dirname(__FILE__) + "/../../../spec_helper")

# TODO using this seam as an interim way to get the file to load
module Config
  CONFIG = {
    'bindir' => 'foo',
    'ruby_install_name' => 'bar'
  }
end
require 'generators/cucumber/install/install_base'

module Cucumber
  module Generators
    describe InstallBase do
      def instance_of_class_including(mixin)
        Class.new do
          include mixin
        end.new
      end
      
      before(:each) do
        Kernel.stub(:require => nil)
        
        @generator = instance_of_class_including(Cucumber::Generators::InstallBase)
      end
      
      # This is a private method, but there was a bug in it where it
      # defaulted to :testunit (the framework) when called to identify
      # the driver
      describe "#first_loadable" do
        it "detects loadable libraries" do
          Gem.should_receive(:available?).with('capybara').and_return(true)
          @generator.send(:first_loadable, [['capybara', :capybara], ['webrat', :webrat ]]).should == :capybara
        end        

        it "tries the given libraries in order" do
          Gem.stub(:available?).with('capybara').and_return(false)
          Gem.should_receive(:available?).with('webrat').and_return(true)
          @generator.send(:first_loadable, [['capybara', :capybara], ['webrat', :webrat ]]).should == :webrat
        end
        
        it "returns nil if no libraries are available" do
          Gem.stub(:available? => false)
          @generator.send(:first_loadable, [['capybara', :capybara], ['webrat', :webrat ]]).should be_nil
        end
      end
      
      # This is a private method, but there may have been a bug in it where
      # it defaulted to :testunit (the framework) when called to identify
      # the driver
      describe "#detect_in_env" do
        describe "when env.rb doesn't exist" do
          it "returns nil" do
            File.should_receive(:file?).with("features/support/env.rb").and_return(false)
            @generator.send(:detect_in_env, [['capybara', :capybara], ['webrat', :webrat]]).should be_nil
          end
        end
        
        describe "when env.rb exists" do
          before(:each) do
            File.stub(:file => true)
          end
          
          it "detects loadable libraries, choosing the first in the argument list" do
            IO.should_receive(:read).with("features/support/env.rb").and_return("blah webrat capybara blah")
            @generator.send(:detect_in_env, [['capybara', :capybara], ['webrat', :webrat]]).should == :capybara
          end        

          it "tries the given libraries in order" do
            IO.should_receive(:read).with("features/support/env.rb").and_return("blah webrat blah")
            @generator.send(:detect_in_env, [['capybara', :capybara], ['webrat', :webrat]]).should == :webrat
          end
        
          it "returns nil if no libraries are available" do
            IO.should_receive(:read).with("features/support/env.rb").and_return("blah blah")
            @generator.send(:detect_in_env, [['capybara', :capybara], ['webrat', :webrat]]).should be_nil
          end
        end
        
      end
      
    end
  end
end
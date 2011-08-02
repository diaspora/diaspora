require 'spec_helper'
require 'yaml'

module Cucumber
  module Cli
    describe ProfileLoader do
      def given_cucumber_yml_defined_as(hash_or_string)
        Dir.stub!(:glob).with('{,.config/,config/}cucumber{.yml,.yaml}').and_return(['cucumber.yml'])
        File.stub!(:exist?).and_return(true)
        cucumber_yml = hash_or_string.is_a?(Hash) ? hash_or_string.to_yaml : hash_or_string
        IO.stub!(:read).with('cucumber.yml').and_return(cucumber_yml)
      end

      def loader
        ProfileLoader.new
      end

      it "treats backslashes as literals in rerun.txt when on Windows (JRuby or MRI)" do
        given_cucumber_yml_defined_as({'default' => '--format "pretty" features\sync_imap_mailbox.feature:16:22'})
        if(Cucumber::WINDOWS)
          loader.args_from('default').should == ['--format','pretty','features\sync_imap_mailbox.feature:16:22']
        else
          loader.args_from('default').should == ['--format','pretty','featuressync_imap_mailbox.feature:16:22']
        end

      end

      it "treats forward slashes as literals" do
        given_cucumber_yml_defined_as({'default' => '--format "ugly" features/sync_imap_mailbox.feature:16:22'})
        loader.args_from('default').should == ['--format','ugly','features/sync_imap_mailbox.feature:16:22']
      end

    end
  end
end

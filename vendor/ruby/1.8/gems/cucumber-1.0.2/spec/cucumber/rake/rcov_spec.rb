require 'spec_helper'
require 'cucumber/rake/task'
require 'rake'

module Cucumber
  module Rake

    describe Task::RCovCucumberRunner do

      let(:libs) { ['lib'] }
      let(:binary) { Cucumber::BINARY }
      let(:cucumber_opts) { ['--cuke-option'] }
      let(:feature_files) { [] }
      let(:rcov_opts) { ['--rcov-option'] }


      context "when running with bundler" do

        let(:bundler) { true }

        subject { Task::RCovCucumberRunner.new(
            libs, binary, cucumber_opts, bundler, feature_files, rcov_opts) }

        it "does use bundler if bundler is set to true" do
          subject.use_bundler.should be_true
        end

        it "uses bundle exec to find cucumber and libraries" do
          subject.cmd.should == [Cucumber::RUBY_BINARY,
                                 '-S',
                                 'bundle',
                                 'exec',
                                 'rcov',
                                 '--rcov-option',
                                 "\"#{Cucumber::BINARY }\"",
                                 '--',
                                 '--cuke-option'] + feature_files
        end

      end

      context "when running without bundler" do

        let(:bundler) { false }

        subject { Task::RCovCucumberRunner.new(
            libs, binary, cucumber_opts, bundler, feature_files, rcov_opts) }

        it "does not use bundler if bundler is set to false" do
          subject.use_bundler.should be_false
        end

        it "uses well known cucumber location and specified libraries" do
          subject.cmd.should == [Cucumber::RUBY_BINARY,
                                 '-I',
                                 '"lib"',
                                 '-S',
                                 'rcov',
                                 '--rcov-option',
                                 "\"#{Cucumber::BINARY }\"",
                                 '--',
                                 '--cuke-option'] + feature_files
        end
        
      end


    end

  end
end
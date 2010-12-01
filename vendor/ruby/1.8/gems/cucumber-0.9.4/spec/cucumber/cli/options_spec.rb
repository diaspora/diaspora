require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'
require 'cucumber/cli/options'

module Cucumber
module Cli
  describe Options do

    def given_cucumber_yml_defined_as(hash_or_string)
      File.stub!(:exist?).and_return(true)
      cucumber_yml = hash_or_string.is_a?(Hash) ? hash_or_string.to_yaml : hash_or_string
      IO.stub!(:read).with('cucumber.yml').and_return(cucumber_yml)
    end

    before(:each) do
      File.stub!(:exist?).and_return(false) # Meaning, no cucumber.yml exists
      Kernel.stub!(:exit).and_return(nil)
    end

    def output_stream
      @output_stream ||= StringIO.new
    end

    def error_stream
      @error_stream ||= StringIO.new
    end

    def options
      @options ||= Options.new(output_stream, error_stream)
    end

    def prepare_args(args)
      args.is_a?(Array) ? args : args.split(' ')
    end

    describe 'parsing' do

      def when_parsing(args)
        yield
        options.parse!(prepare_args(args))
      end

      def after_parsing(args)
        options.parse!(prepare_args(args))
        yield
      end

      context '-r or --require' do
        it "collects all specified files into an array" do
          after_parsing('--require some_file.rb -r another_file.rb') do
            options[:require].should == ['some_file.rb', 'another_file.rb']
          end
        end
      end

      context '--i18n' do
        context "with LANG specified as 'help'" do
          it "lists all known langues" do
            when_parsing '--i18n help' do
              Kernel.should_receive(:exit)
            end
          end

          it "exits the program" do
            when_parsing('--i18n help') { Kernel.should_receive(:exit) }
          end
        end
      end

      context "--port PORT" do
        it "sets the drb_port to the provided option" do
          after_parsing('--port 4500') { options[:drb_port].should == '4500' }
        end
      end

      context '-f FORMAT or --format FORMAT' do
        it "defaults the output for the formatter to the output stream (STDOUT)" do
          after_parsing('-f pretty') { options[:formats].should == [['pretty', output_stream]] }
        end
      end

      context '-o [FILE|DIR] or --out [FILE|DIR]' do
        it "defaults the formatter to 'pretty' when not specified earlier" do
          after_parsing('-o file.txt') { options[:formats].should == [['pretty', 'file.txt']] }
        end
        it "sets the output for the formatter defined immediatly before it" do
          after_parsing('-f profile --out file.txt -f pretty -o file2.txt') do
            options[:formats].should == [['profile', 'file.txt'], ['pretty', 'file2.txt']]
          end
        end
      end

      context '-t TAGS --tags TAGS' do
        it "designates tags prefixed with ~ as tags to be excluded" do
          after_parsing('--tags ~@foo,@bar') { options[:tag_expressions].should == ['~@foo,@bar'] }
        end

        it "stores tags passed with different --tags seperately" do
          after_parsing('--tags @foo --tags @bar') { options[:tag_expressions].should == ['@foo', '@bar'] }
        end
      end

      context '-n NAME or --name NAME' do
        it "stores the provided names as regular expressions" do
          after_parsing('-n foo --name bar') { options[:name_regexps].should == [/foo/,/bar/] }
        end
      end

      context '-e PATTERN or --exclude PATTERN' do
        it "stores the provided exclusions as regular expressions" do
          after_parsing('-e foo --exclude bar') { options[:excludes].should == [/foo/,/bar/] }
        end
      end

      context '-p PROFILE or --profile PROFILE' do

        it "notifies the user that an individual profile is being used" do
          given_cucumber_yml_defined_as({'foo' => [1,2,3]})
          options.parse!(%w{--profile foo})
          output_stream.string.should =~ /Using the foo profile...\n/
        end

        it "notifies the user when multiple profiles are being used" do
          given_cucumber_yml_defined_as({'foo' => [1,2,3], 'bar' => ['v'], 'dog' => ['v']})
          options.parse!(%w{--profile foo --profile bar --profile dog})
          output_stream.string.should =~ /Using the foo, bar and dog profiles...\n/
        end

        it "notifies the user of all profiles being used, even when they are nested" do
          given_cucumber_yml_defined_as('foo' => '-p bar', 'bar' => 'features')
          after_parsing('-p foo') do
            output_stream.string.should =~ /Using the foo and bar profiles.../
          end
        end

        it "uses the default profile passed in during initialization if none are specified by the user" do
          given_cucumber_yml_defined_as({'default' => '--require some_file'})

          options = Options.new(output_stream, error_stream, :default_profile => 'default')
          options.parse!(%w{--format progress})
          options[:require].should include('some_file')
        end

        it "merges all uniq values from both cmd line and the profile" do
          given_cucumber_yml_defined_as('foo' => %w[--verbose])
          options.parse!(%w[--wip --profile foo])
          options[:wip].should be_true
          options[:verbose].should be_true
        end

        it "gives precendene to the origianl options' paths" do
          given_cucumber_yml_defined_as('foo' => %w[features])
          options.parse!(%w[my.feature -p foo])
          options[:paths].should == %w[my.feature]
        end

        it "combines the require files of both" do
          given_cucumber_yml_defined_as('bar' => %w[--require features -r dog.rb])
          options.parse!(%w[--require foo.rb -p bar])
          options[:require].should == %w[foo.rb features dog.rb]
        end

        it "combines the tag names of both" do
          given_cucumber_yml_defined_as('baz' => %w[-t @bar])
          options.parse!(%w[--tags @foo -p baz])
          options[:tag_expressions].should == ["@foo", "@bar"]
        end

        it "only takes the paths from the original options, and disgregards the profiles" do
          given_cucumber_yml_defined_as('baz' => %w[features])
          options.parse!(%w[my.feature -p baz])
          options[:paths].should == ['my.feature']
        end

        it "uses the paths from the profile when none are specified originally" do
          given_cucumber_yml_defined_as('baz' => %w[some.feature])
          options.parse!(%w[-p baz])
          options[:paths].should == ['some.feature']
        end

        it "combines environment variables from the profile but gives precendene to cmd line args" do
          given_cucumber_yml_defined_as('baz' => %w[FOO=bar CHEESE=swiss])
          options.parse!(%w[-p baz CHEESE=cheddar BAR=foo])
          options[:env_vars].should == {'BAR' => 'foo', 'FOO' => 'bar', 'CHEESE' => 'cheddar'}
        end

        it "disregards STDOUT formatter defined in profile when another is passed in (via cmd line)" do
          given_cucumber_yml_defined_as({'foo' => %w[--format pretty]})
          options.parse!(%w{--format progress --profile foo})
          options[:formats].should == [['progress', output_stream]]
        end

        it "includes any non-STDOUT formatters from the profile" do
          given_cucumber_yml_defined_as({'html' => %w[--format html -o features.html]})
          options.parse!(%w{--format progress --profile html})
          options[:formats].should == [['progress', output_stream], ['html', 'features.html']]
        end

        it "does not include STDOUT formatters from the profile if there is a STDOUT formatter in command line" do
          given_cucumber_yml_defined_as({'html' => %w[--format html -o features.html --format pretty]})
          options.parse!(%w{--format progress --profile html})
          options[:formats].should == [['progress', output_stream], ['html', 'features.html']]
        end

        it "includes any STDOUT formatters from the profile if no STDOUT formatter was specified in command line" do
          given_cucumber_yml_defined_as({'html' => %w[--format html]})
          options.parse!(%w{--format rerun -o rerun.txt --profile html})
          options[:formats].should == [['html', output_stream], ['rerun', 'rerun.txt']]
        end

        it "assumes all of the formatters defined in the profile when none are specified on cmd line" do
          given_cucumber_yml_defined_as({'html' => %w[--format progress --format html -o features.html]})
          options.parse!(%w{--profile html})
          options[:formats].should == [['progress', output_stream], ['html', 'features.html']]
        end

        it "respects --quiet when defined in the profile" do
          given_cucumber_yml_defined_as('foo' => '-q')
          options.parse!(%w[-p foo])
          options[:snippets].should be_false
          options[:source].should be_false
        end
      end

      context '-P or --no-profile' do

        it "disables profiles" do
          given_cucumber_yml_defined_as({'default' => '-v --require file_specified_in_default_profile.rb'})

          after_parsing("-P --require some_file.rb") do
            options[:require].should == ['some_file.rb']
          end
        end

        it "notifies the user that the profiles are being disabled" do
          given_cucumber_yml_defined_as({'default' => '-v'})

          after_parsing("--no-profile --require some_file.rb") do
            output_stream.string.should =~ /Disabling profiles.../
          end
        end

      end

      context '-b or --backtrace' do
        it "turns on cucumber's full backtrace" do
          when_parsing("-b") do
            Cucumber.should_receive(:use_full_backtrace=).with(true)
          end
        end
      end

      context '--version' do
        it "displays Cucumber's version" do
          after_parsing('--version') do
            output_stream.string.should =~ /#{Cucumber::VERSION}/
          end
        end
        it "exits the program" do
          when_parsing('--version') { Kernel.should_receive(:exit) }
        end
      end

      context 'environment variables (i.e. MODE=webrat)' do
        it "places all of the environment variables into a hash" do
          after_parsing('MODE=webrat FOO=bar') do
            options[:env_vars].should == {'MODE' => 'webrat', 'FOO' => 'bar'}
          end
        end
      end

      it "assigns any extra arguments as paths to features" do
        after_parsing('-f pretty my_feature.feature my_other_features') do
          options[:paths].should == ['my_feature.feature', 'my_other_features']
        end
      end

      it "does not mistake environment variables as feature paths" do
        after_parsing('my_feature.feature FOO=bar') do
          options[:paths].should == ['my_feature.feature']
        end
      end
    end

    describe '#expanded_args_without_drb' do
      it "returns the orginal args in additon to the args from any profiles" do
        given_cucumber_yml_defined_as('foo' => '-v',
                                      'bar' => '--wip -p baz',
                                      'baz' => '-r some_file.rb')
        options.parse!(%w[features -p foo --profile bar])

        options.expanded_args_without_drb.should == %w[features -v --wip -r some_file.rb --no-profile]
      end

      it "removes the --drb flag so that the args can be safely passed to the drb server" do
        given_cucumber_yml_defined_as('default' => 'features -f pretty --drb')
        options.parse!(%w[--profile default])

        options.expanded_args_without_drb.should == %w[features -f pretty --no-profile]
      end

      it "contains the environment variables" do
        options.parse!(%w[features FOO=bar])
        options.expanded_args_without_drb.should == %w[features FOO=bar --no-profile]
      end

      it "ignores the paths from the profiles if one was specified on the command line" do
        given_cucumber_yml_defined_as('foo' => 'features --drb')
        options.parse!(%w[some_feature.feature -p foo])
        options.expanded_args_without_drb.should == %w[some_feature.feature --no-profile]
      end


      it "appends the --no-profile flag so that the DRb server doesn't reload the profiles" do
        given_cucumber_yml_defined_as('foo' => 'features --drb')
        options.parse!(%w[some_feature.feature -p foo])
        options.expanded_args_without_drb.should == %w[some_feature.feature --no-profile]
      end

      it "does not append --no-profile if already present" do
        options.parse!(%w[some_feature.feature -P])
        options.expanded_args_without_drb.should == %w[some_feature.feature -P]
      end


    end

    describe "dry-run" do 
      it "should have the default value for snippets" do
        given_cucumber_yml_defined_as({'foo' => %w[--dry-run]})
        options.parse!(%w{--dry-run})
        options[:snippets].should == true
      end

      it "should set snippets to false when no-snippets provided after dry-run" do 
        given_cucumber_yml_defined_as({'foo' => %w[--dry-run --no-snippets]})
        options.parse!(%w{--dry-run --no-snippets})
        options[:snippets].should == false
      end

      it "should set snippets to false when no-snippets provided before dry-run" do 
        given_cucumber_yml_defined_as({'foo' => %w[--no-snippet --dry-run]})
        options.parse!(%w{--no-snippets --dry-run})
        options[:snippets].should == false
      end
    end
  end

end
end


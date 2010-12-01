require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'

module Cucumber
module Cli
  describe Configuration do
    module ExposesOptions
      attr_reader :options
    end

    def given_cucumber_yml_defined_as(hash_or_string)
      File.stub!(:exist?).and_return(true)
      cucumber_yml = hash_or_string.is_a?(Hash) ? hash_or_string.to_yaml : hash_or_string
      IO.stub!(:read).with('cucumber.yml').and_return(cucumber_yml)
    end

    def given_the_following_files(*files)
      File.stub!(:directory?).and_return(true)
      File.stub!(:file?).and_return(true)
      Dir.stub!(:[]).and_return(files)
    end

    before(:each) do
      File.stub!(:exist?).and_return(false) # Meaning, no cucumber.yml exists
      Kernel.stub!(:exit).and_return(nil)
    end

    def config
      @config ||= Configuration.new(@out = StringIO.new, @error = StringIO.new).extend(ExposesOptions)
    end

    def reset_config
      @config = nil
    end

    attr_reader :out, :error

    it "should require env.rb files first" do
      given_the_following_files("/features/support/a_file.rb","/features/support/env.rb")

      config.parse!(%w{--require /features})

      config.support_to_load.should == [
        "/features/support/env.rb",
        "/features/support/a_file.rb"
      ]
    end

    it "should not require env.rb files when --dry-run" do
      given_the_following_files("/features/support/a_file.rb","/features/support/env.rb")

      config.parse!(%w{--require /features --dry-run})

      config.support_to_load.should == [
        "/features/support/a_file.rb"
      ]
    end

    it "should require files in vendor/{plugins,gems}/*/cucumber/*.rb" do
      given_the_following_files("/vendor/gems/gem_a/cucumber/bar.rb",
                                "/vendor/plugins/plugin_a/cucumber/foo.rb")

      config.parse!(%w{--require /features})

      config.step_defs_to_load.should == [
        "/vendor/gems/gem_a/cucumber/bar.rb",
        "/vendor/plugins/plugin_a/cucumber/foo.rb"
      ]
    end

    describe "--exclude" do

      it "excludes a ruby file from requiring when the name matches exactly" do
        given_the_following_files("/features/support/a_file.rb","/features/support/env.rb")

        config.parse!(%w{--require /features --exclude a_file.rb})

        config.all_files_to_load.should == [
          "/features/support/env.rb"
        ]
      end

      it "excludes all ruby files that match the provided patterns from requiring" do
        given_the_following_files("/features/support/foof.rb","/features/support/bar.rb",
                                  "/features/support/food.rb","/features/blah.rb",
                                  "/features/support/fooz.rb")

        config.parse!(%w{--require /features --exclude foo[df] --exclude blah})

        config.all_files_to_load.should == [
          "/features/support/bar.rb",
          "/features/support/fooz.rb"
        ]
      end
    end

    describe '#drb?' do
      it "indicates whether the --drb flag was passed in or not" do
        config.parse!(%w{features})
        config.should_not be_drb


        config.parse!(%w{features --drb})
        config.should be_drb
      end
    end

    describe "#drb_port" do
      it "is nil when not configured" do
        config.parse!([])
        config.drb_port.should be_nil
      end

      it "is numeric when configured" do
        config.parse!(%w{features --port 1000})
        config.drb_port.should == 1000
      end


    end

    it "uses the default profile when no profile is defined" do
      given_cucumber_yml_defined_as({'default' => '--require some_file'})

      config.parse!(%w{--format progress})
      config.options[:require].should include('some_file')
    end

    context '--profile' do

      it "expands args from profiles in the cucumber.yml file" do
        given_cucumber_yml_defined_as({'bongo' => '--require from/yml'})

        config.parse!(%w{--format progress --profile bongo})
        config.options[:formats].should == [['progress', out]]
        config.options[:require].should == ['from/yml']
      end

      it "expands args from the default profile when no flags are provided" do
        given_cucumber_yml_defined_as({'default' => '--require from/yml'})

        config.parse!([])
        config.options[:require].should == ['from/yml']
      end

      it "allows --strict to be set by a profile" do
        given_cucumber_yml_defined_as({'bongo' => '--strict'})

        config.parse!(%w{--profile bongo})
        config.options[:strict].should be_true
      end

      it "parses ERB syntax in the cucumber.yml file" do
        given_cucumber_yml_defined_as({'default' => '<%="--require some_file"%>'})

        config.parse!([])
        config.options[:require].should include('some_file')
      end

      it "parses ERB in cucumber.yml that makes uses nested ERB sessions" do
        given_cucumber_yml_defined_as(<<ERB_YML)
<%= ERB.new({'standard' => '--require some_file'}.to_yaml).result %>
<%= ERB.new({'enhanced' => '--require other_file'}.to_yaml).result %>
ERB_YML

        config.parse!(%w(-p standard))
        config.options[:require].should include('some_file')
      end

      it "provides a helpful error message when a specified profile does not exists in cucumber.yml" do
        given_cucumber_yml_defined_as({'default' => '--require from/yml', 'html_report' =>  '--format html'})

        expected_message = <<-END_OF_MESSAGE
Could not find profile: 'i_do_not_exist'

Defined profiles in cucumber.yml:
  * default
  * html_report
END_OF_MESSAGE

        lambda{config.parse!(%w{--profile i_do_not_exist})}.should raise_error(ProfileNotFound, expected_message)
      end

      it "allows profiles to be defined in arrays" do
        given_cucumber_yml_defined_as({'foo' => ['-f','progress']})

        config.parse!(%w{--profile foo})
        config.options[:formats].should == [['progress', out]]
      end

      it "disregards default STDOUT formatter defined in profile when another is passed in (via cmd line)" do
        given_cucumber_yml_defined_as({'foo' => %w[--format pretty]})
        config.parse!(%w{--format progress --profile foo})
        config.options[:formats].should == [['progress', out]]#, ['pretty', 'pretty.txt']]
      end



      ["--no-profile", "-P"].each do |flag|
        context 'when none is specified with #{flag}' do
          it "disables profiles" do
            given_cucumber_yml_defined_as({'default' => '-v --require file_specified_in_default_profile.rb'})

            config.parse!("#{flag} --require some_file.rb".split(" "))
            config.options[:require].should == ['some_file.rb']
          end

          it "notifies the user that the profiles are being disabled" do
            given_cucumber_yml_defined_as({'default' => '-v'})

            config.parse!("#{flag} --require some_file.rb".split(" "))
            out.string.should =~ /Disabling profiles.../
          end
        end
      end

      it "issues a helpful error message when a specified profile exists but is nil or blank" do
        [nil, '   '].each do |bad_input|
          given_cucumber_yml_defined_as({'foo' => bad_input})

          expected_error = /The 'foo' profile in cucumber.yml was blank.  Please define the command line arguments for the 'foo' profile in cucumber.yml./
          lambda{config.parse!(%w{--profile foo})}.should raise_error(expected_error)
        end
      end

      it "issues a helpful error message when no YAML file exists and a profile is specified" do
        File.should_receive(:exist?).with('cucumber.yml').and_return(false)

        expected_error = /cucumber\.yml was not found/
        lambda{config.parse!(%w{--profile i_do_not_exist})}.should raise_error(expected_error)
      end

      it "issues a helpful error message when cucumber.yml is blank or malformed" do
          expected_error_message = /cucumber\.yml was found, but was blank or malformed. Please refer to cucumber's documentation on correct profile usage./

        ['', 'sfsadfs', "--- \n- an\n- array\n", "---dddfd"].each do |bad_input|
          given_cucumber_yml_defined_as(bad_input)
          lambda{config.parse!([])}.should raise_error(expected_error_message)
          reset_config
        end
      end

      it "issues a helpful error message when cucumber.yml can not be parsed" do
        expected_error_message = /cucumber.yml was found, but could not be parsed. Please refer to cucumber's documentation on correct profile usage./

        given_cucumber_yml_defined_as("input that causes an exception in YAML loading")
        YAML.should_receive(:load).and_raise ArgumentError

        lambda{config.parse!([])}.should raise_error(expected_error_message)
      end

      it "issues a helpful error message when cucumber.yml can not be parsed by ERB" do
        expected_error_message = /cucumber.yml was found, but could not be parsed with ERB.  Please refer to cucumber's documentation on correct profile usage./
        given_cucumber_yml_defined_as("<% this_fails %>")

        lambda{config.parse!([])}.should raise_error(expected_error_message)
      end
    end


    it "should accept --dry-run option" do
      config.parse!(%w{--dry-run})
      config.options[:dry_run].should be_true
    end

    it "should accept --no-source option" do
      config.parse!(%w{--no-source})

      config.options[:source].should be_false
    end

    it "should accept --no-snippets option" do
      config.parse!(%w{--no-snippets})

      config.options[:snippets].should be_false
    end

    it "should set snippets and source to false with --quiet option" do
      config.parse!(%w{--quiet})

      config.options[:snippets].should be_false
      config.options[:source].should be_false
    end

    it "should accept --verbose option" do
      config.parse!(%w{--verbose})

      config.options[:verbose].should be_true
    end

    it "should accept --out option" do
      config.parse!(%w{--out jalla.txt})
      config.formats.should == [['pretty', 'jalla.txt']]
    end

    it "should accept multiple --out options" do
      config.parse!(%w{--format progress --out file1 --out file2})
      config.formats.should == [['progress', 'file2']]
    end

    it "should accept multiple --format options and put the STDOUT one first so progress is seen" do
      config.parse!(%w{--format pretty --out pretty.txt --format progress})
      config.formats.should == [['progress', out], ['pretty', 'pretty.txt']]
    end

    it "should not accept multiple --format options when both use implicit STDOUT" do
      lambda do
        config.parse!(%w{--format pretty --format progress})
      end.should raise_error("All but one formatter must use --out, only one can print to each stream (or STDOUT)")
    end

    it "should not accept multiple --out streams pointing to the same place" do
      lambda do
        config.parse!(%w{--format pretty --out file1 --format progress --out file1})
      end.should raise_error("All but one formatter must use --out, only one can print to each stream (or STDOUT)")
    end

    it "should associate --out to previous --format" do
      config.parse!(%w{--format progress --out file1 --format profile --out file2})
      config.formats.should == [["progress", "file1"], ["profile" ,"file2"]]
    end

    it "should accept --color option" do
      Term::ANSIColor.should_receive(:coloring=).with(true)
      config.parse!(['--color'])
    end

    it "should accept --no-color option" do
      Term::ANSIColor.should_receive(:coloring=).with(false)
      config = Configuration.new(StringIO.new)
      config.parse!(['--no-color'])
    end

    describe "--backtrace" do
      before do
        Cucumber.use_full_backtrace = false
      end

      it "should show full backtrace when --backtrace is present" do
        config = Main.new(['--backtrace'])
        begin
          "x".should == "y"
        rescue => e
          e.backtrace[0].should_not == "#{__FILE__}:#{__LINE__ - 2}"
        end
      end

      after do
        Cucumber.use_full_backtrace = false
      end
    end

    it "should accept multiple --name options" do
      config.parse!(['--name', "User logs in", '--name', "User signs up"])

      config.options[:name_regexps].should include(/User logs in/)
      config.options[:name_regexps].should include(/User signs up/)
    end

    it "should accept multiple -n options" do
      config.parse!(['-n', "User logs in", '-n', "User signs up"])

      config.options[:name_regexps].should include(/User logs in/)
      config.options[:name_regexps].should include(/User signs up/)
    end

    it "should preserve the order of the feature files" do
      config.parse!(%w{b.feature c.feature a.feature})

      config.feature_files.should == ["b.feature", "c.feature", "a.feature"]
    end

    it "should search for all features in the specified directory" do
      File.stub!(:directory?).and_return(true)
      Dir.should_receive(:[]).with("feature_directory/**/*.feature").
        any_number_of_times.and_return(["cucumber.feature"])

      config.parse!(%w{feature_directory/})

      config.feature_files.should == ["cucumber.feature"]
    end

    it "defaults to the features directory when no feature file are provided" do
      File.stub!(:directory?).and_return(true)
      Dir.should_receive(:[]).with("features/**/*.feature").
        any_number_of_times.and_return(["cucumber.feature"])

      config.parse!(%w{})

      config.feature_files.should == ["cucumber.feature"]
    end

    it "should allow specifying environment variables on the command line" do
      config.parse!(["foo=bar"])
      ENV["foo"].should == "bar"
      config.feature_files.should_not include('foo=bar')
    end

    it "should allow specifying environment variables in profiles" do
      given_cucumber_yml_defined_as({'selenium' => 'RAILS_ENV=selenium'})
      config.parse!(["--profile", "selenium"])
      ENV["RAILS_ENV"].should == "selenium"
      config.feature_files.should_not include('RAILS_ENV=selenium')
    end
    
    describe "#tag_expression" do
      it "returns an empty expression when no tags are specified" do
        config.parse!([])
        config.tag_expression.should be_empty
      end

      it "returns an expression when tags are specified" do
        config.parse!(['--tags','@foo'])
        config.tag_expression.should_not be_empty
      end
    end
    
    describe "#dry_run?" do
      it "returns true when --dry-run was specified on in the arguments" do
        config.parse!(['--dry-run'])
        config.dry_run?.should be_true
      end
      
      it "returns false by default" do
        config.parse!([])
        config.dry_run?.should be_false
      end
    end
  end
end
end

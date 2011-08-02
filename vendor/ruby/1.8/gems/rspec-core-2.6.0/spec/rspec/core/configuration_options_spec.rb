require 'spec_helper'
require 'ostruct'
require 'tmpdir'

describe RSpec::Core::ConfigurationOptions do

  def config_options_object(*args)
    coo = RSpec::Core::ConfigurationOptions.new(args)
    coo.parse_options
    coo
  end

  def parse_options(*args)
    config_options_object(*args).options
  end

  describe "#configure" do
    it "sends libs before requires" do
      opts = config_options_object(*%w[--require a/path -I a/lib])
      config = double("config").as_null_object
      config.should_receive(:libs=).ordered
      config.should_receive(:requires=).ordered
      opts.configure(config)
    end

    it "sends requires before formatter" do
      opts = config_options_object(*%w[--require a/path -f a/formatter])
      config = double("config").as_null_object
      config.should_receive(:requires=).ordered
      config.should_receive(:add_formatter).ordered
      opts.configure(config)
    end
  end

  describe "-c, --color, and --colour" do
    it "sets :color_enabled => true" do
      parse_options('-c').should include(:color_enabled => true)
      parse_options('--color').should include(:color_enabled => true)
      parse_options('--colour').should include(:color_enabled => true)
    end
  end

  describe "--no-color" do
    it "sets :color_enabled => false" do
      parse_options('--no-color').should include(:color_enabled => false)
    end
  end

  describe "-I" do
    example "adds to :libs" do
      parse_options('-I', 'a_dir').should include(:libs => ['a_dir'])
    end
    example "can be used more than once" do
      parse_options('-I', 'dir_1', '-I', 'dir_2').should include(:libs => ['dir_1','dir_2'])
    end
  end

  describe '--require' do
    example "requires files" do
      parse_options('--require', 'a/path').should include(:requires => ['a/path'])
    end
    example "can be used more than once" do
      parse_options('--require', 'path/1', '--require', 'path/2').should include(:requires => ['path/1','path/2'])
    end
  end

  describe "--format, -f" do
    it "sets :formatter" do
      parse_options('--format', 'd').should include(:formatters => [['d']])
      parse_options('-f', 'd').should include(:formatters => [['d']])
      parse_options('-fd').should include(:formatters => [['d']])
    end

    example "can accept a class name" do
      parse_options('-fSome::Formatter::Class').should include(:formatters => [['Some::Formatter::Class']])
    end
  end

  describe "--profile, -p" do
    it "sets :profile_examples => true" do
      parse_options('-p').should include(:profile_examples => true)
      parse_options('--profile').should include(:profile_examples => true)
    end
  end

  describe '--line_number' do
    it "sets :line_number" do
      parse_options('-l','3').should include(:line_number => '3')
      parse_options('--line_number','3').should include(:line_number => '3')
    end
  end

  describe "--example" do
    it "sets :full_description" do
      parse_options('--example','foo').should include(:full_description => /foo/)
      parse_options('-e','bar').should include(:full_description => /bar/)
    end
  end

  describe "--backtrace, -b" do
    it "sets full_backtrace on config" do
      parse_options("--backtrace").should include(:full_backtrace => true)
      parse_options("-b").should include(:full_backtrace => true)
    end
  end

  describe "--debug, -d" do
    it "sets :debug => true" do
      parse_options("--debug").should include(:debug => true)
      parse_options("-d").should include(:debug => true)
    end
  end

  describe "--fail-fast" do
    it "defaults to false" do
      parse_options[:fail_fast].should be_false
    end

    it "sets fail_fast on config" do
      parse_options("--fail-fast")[:fail_fast].should be_true
    end
  end

  describe "--options" do
    it "sets :custom_options_file" do
      parse_options(*%w[-O my.opts]).should include(:custom_options_file => "my.opts")
      parse_options(*%w[--options my.opts]).should include(:custom_options_file => "my.opts")
    end
  end

  describe "--drb, -X" do
    context "combined with --debug" do
      it "turns off the debugger if --drb is specified first" do
        config_options_object("--drb", "--debug").drb_argv.should_not include("--debug")
        config_options_object("--drb", "-d"     ).drb_argv.should_not include("--debug")
        config_options_object("-X",    "--debug").drb_argv.should_not include("--debug")
        config_options_object("-X",    "-d"     ).drb_argv.should_not include("--debug")
      end

      it "turns off the debugger option if --drb is specified later" do
        config_options_object("--debug", "--drb").drb_argv.should_not include("--debug")
        config_options_object("-d",      "--drb").drb_argv.should_not include("--debug")
        config_options_object("--debug", "-X"   ).drb_argv.should_not include("--debug")
        config_options_object("-d",      "-X"   ).drb_argv.should_not include("--debug")
      end

      it "turns off the debugger option if --drb is specified in the options file" do
        File.stub(:exist?) { true }
        IO.stub(:read) { "--drb" }
        config_options_object("--debug").drb_argv.should_not include("--debug")
        config_options_object("-d"     ).drb_argv.should_not include("--debug")
      end

      it "turns off the debugger option if --debug is specified in the options file" do
        File.stub(:exist?) { true }
        IO.stub(:read) { "--debug" }
        config_options_object("--drb").drb_argv.should_not include("--debug")
        config_options_object("-X"   ).drb_argv.should_not include("--debug")
      end
    end

    it "does not send --drb back to the parser after parsing options" do
      config_options_object("--drb", "--color").drb_argv.should_not include("--drb")
    end

  end

  describe "files_or_directories_to_run" do
    it "parses files from '-c file.rb dir/file.rb'" do
      parse_options("-c", "file.rb", "dir/file.rb").should include(:files_or_directories_to_run => ["file.rb", "dir/file.rb"])
    end

    it "parses dir from 'dir'" do
      parse_options("dir").should include(:files_or_directories_to_run => ["dir"])
    end

    it "parses dir and files from 'spec/file1_spec.rb, spec/file2_spec.rb'" do
      parse_options("dir", "spec/file1_spec.rb", "spec/file2_spec.rb").should include(:files_or_directories_to_run => ["dir", "spec/file1_spec.rb", "spec/file2_spec.rb"])
    end

    it "provides no files or directories if spec directory does not exist" do
      FileTest.stub(:directory?).with("spec").and_return false
      parse_options().should include(:files_or_directories_to_run => [])
    end

    it "parses dir and files from 'spec/file1_spec.rb, spec/file2_spec.rb'" do
      parse_options("dir", "spec/file1_spec.rb", "spec/file2_spec.rb").should include(:files_or_directories_to_run => ["dir", "spec/file1_spec.rb", "spec/file2_spec.rb"])

    end

  end

  # TODO ensure all options are output
  describe "#drb_argv" do
    it "preserves extra arguments" do
      File.stub(:exist?) { false }
      config_options_object(*%w[ a --drb b --color c ]).drb_argv.should =~ %w[ --color a b c ]
    end

    it "includes --fail-fast" do
      config_options_object(*%w[--fail-fast]).drb_argv.should include("--fail-fast")
    end

    it "includes --options" do
      config_options_object(*%w[--options custom.opts]).drb_argv.should include("--options", "custom.opts")
    end

    context "with tags" do
      it "includes the tags" do
        coo = config_options_object("--tag", "tag")
        coo.drb_argv.should eq(["--tag", "tag"])
      end

      it "leaves tags intact" do
        coo = config_options_object("--tag", "tag")
        coo.drb_argv
        coo.options[:filter].should eq( {:tag=>true} )
      end
    end

    context "with formatters" do
      it "includes the formatters" do
        coo = config_options_object("--format", "d")
        coo.drb_argv.should eq(["--format", "d"])
      end

      it "leaves formatters intact" do
        coo = config_options_object("--format", "d")
        coo.drb_argv
        coo.options[:formatters].should eq([["d"]])
      end

      it "leaves output intact" do
        coo = config_options_object("--format", "p", "--out", "foo.txt", "--format", "d")
        coo.drb_argv
        coo.options[:formatters].should eq([["p","foo.txt"],["d"]])
      end
    end

    context "--drb specified in ARGV" do
      it "renders all the original arguments except --drb" do
        config_options_object(*%w[ --drb --color --format s --line_number 1 --example pattern --profile --backtrace -I path/a -I path/b --require path/c --require path/d]).
          drb_argv.should eq(%w[ --color --profile --backtrace --line_number 1 --example pattern --format s -I path/a -I path/b --require path/c --require path/d])
      end
    end

    context "--drb specified in the options file" do
      it "renders all the original arguments except --drb" do
        File.stub(:exist?) { true }
        IO.stub(:read) { "--drb --color" }
        config_options_object(*%w[ --tty --format s --line_number 1 --example pattern --profile --backtrace ]).
          drb_argv.should eq(%w[ --color --profile --backtrace --tty --line_number 1 --example pattern --format s])
      end
    end

    context "--drb specified in ARGV and the options file" do
      it "renders all the original arguments except --drb" do
        File.stub(:exist?) { true }
        IO.stub(:read) { "--drb --color" }
        config_options_object(*%w[ --drb --format s --line_number 1 --example pattern --profile --backtrace]).
          drb_argv.should eq(%w[ --color --profile --backtrace --line_number 1 --example pattern --format s])
      end
    end

    context "--drb specified in ARGV and in as ARGV-specified --options file" do
      it "renders all the original arguments except --drb and --options" do
        File.stub(:exist?) { true }
        IO.stub(:read) { "--drb --color" }
        config_options_object(*%w[ --drb --format s --line_number 1 --example pattern --profile --backtrace]).
          drb_argv.should eq(%w[ --color --profile --backtrace --line_number 1 --example pattern --format s ])
      end
    end
  end

  describe "sources: ~/.rspec, ./.rspec, custom, CLI, and SPEC_OPTS" do
    let(:local_options_file)  { File.join(Dir.tmpdir, ".rspec-local") }
    let(:global_options_file) { File.join(Dir.tmpdir, ".rspec-global") }
    let(:custom_options_file) { File.join(Dir.tmpdir, "custom.options") }

    before do
      @orig_spec_opts = ENV["SPEC_OPTS"]
      @orig_global_options_file = RSpec::Core::ConfigurationOptions::GLOBAL_OPTIONS_FILE
      @orig_local_options_file  = RSpec::Core::ConfigurationOptions::LOCAL_OPTIONS_FILE
      RSpec::Core::ConfigurationOptions::__send__ :remove_const, :GLOBAL_OPTIONS_FILE
      RSpec::Core::ConfigurationOptions::__send__ :remove_const, :LOCAL_OPTIONS_FILE
      RSpec::Core::ConfigurationOptions::GLOBAL_OPTIONS_FILE = global_options_file
      RSpec::Core::ConfigurationOptions::LOCAL_OPTIONS_FILE  = local_options_file
      FileUtils.rm local_options_file if File.exist? local_options_file
      FileUtils.rm global_options_file if File.exist? global_options_file
      FileUtils.rm custom_options_file if File.exist? custom_options_file
    end

    after do
      ENV["SPEC_OPTS"] = @orig_spec_opts
      RSpec::Core::ConfigurationOptions::__send__ :remove_const, :GLOBAL_OPTIONS_FILE
      RSpec::Core::ConfigurationOptions::__send__ :remove_const, :LOCAL_OPTIONS_FILE
      RSpec::Core::ConfigurationOptions::GLOBAL_OPTIONS_FILE = @orig_global_options_file
      RSpec::Core::ConfigurationOptions::LOCAL_OPTIONS_FILE  = @orig_local_options_file
    end

    def write_options(scope, options)
      File.open(send("#{scope}_options_file"), 'w') { |f| f.write(options) }
    end

    it "merges global, local, SPEC_OPTS, and CLI" do
      write_options(:global, "--color")
      write_options(:local,  "--line 37")
      ENV["SPEC_OPTS"] = "--debug"
      options = parse_options("--drb")
      options[:color_enabled].should be_true
      options[:line_number].should eq("37")
      options[:debug].should be_true
      options[:drb].should be_true
    end

    it "prefers SPEC_OPTS over CLI" do
      ENV["SPEC_OPTS"] = "--format spec_opts"
      parse_options("--format", "cli")[:formatters].should eq([['spec_opts']])
    end

    it "prefers CLI over file options" do
      write_options(:local,  "--format local")
      write_options(:global, "--format global")
      parse_options("--format", "cli")[:formatters].should eq([['cli']])
    end

    it "prefers local file options over global" do
      write_options(:local,  "--format local")
      write_options(:global, "--format global")
      parse_options[:formatters].should eq([['local']])
    end

    context "with custom options file" do
      it "ignores local and global options files" do
        write_options(:local, "--color")
        write_options(:global, "--color")
        parse_options("-O", custom_options_file)[:color_enabled].should be_false
      end
    end
  end
end

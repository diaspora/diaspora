require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Jasmine::Config do

  describe "configuration" do

    before(:all) do
      temp_dir_before

      Dir::chdir @tmp
      `rails rails-project`
      Dir::chdir 'rails-project'

      FileUtils.cp_r(File.join(@root, 'generators'), 'vendor')

      `./script/generate jasmine`

      Dir::chdir @old_dir

      @rails_dir = "#{@tmp}/rails-project"
    end

    after(:all) do
      temp_dir_after
    end

    before(:each) do
      @template_dir = File.expand_path(File.join(File.dirname(__FILE__), "../generators/jasmine/templates"))
      @config = Jasmine::Config.new
    end

    describe "defaults" do

      it "src_dir uses root when src dir is blank" do
        @config.stub!(:project_root).and_return('some_project_root')
        @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))
        YAML.stub!(:load).and_return({'src_dir' => nil})
        @config.src_dir.should == 'some_project_root'
      end

      it "should use correct default yaml config" do
        @config.stub!(:project_root).and_return('some_project_root')
        @config.simple_config_file.should == (File.join('some_project_root', 'spec/javascripts/support/jasmine.yml'))
      end

    end


    describe "simple_config" do
      before(:each) do
        @config.stub!(:src_dir).and_return(File.join(@rails_dir, "."))
        @config.stub!(:spec_dir).and_return(File.join(@rails_dir, "spec/javascripts"))
      end

      shared_examples_for "simple_config defaults" do
        it "should return the correct files and mappings" do
          @config.src_files.should == []
          @config.stylesheets.should == []
          @config.spec_files.should == ['PlayerSpec.js']
          @config.helpers.should == ['helpers/SpecHelper.js']
          @config.js_files.should == [
            '/__spec__/helpers/SpecHelper.js',
            '/__spec__/PlayerSpec.js',
          ]
          @config.js_files("PlayerSpec.js").should ==
            ['/__spec__/helpers/SpecHelper.js',
             '/__spec__/PlayerSpec.js']
          @config.spec_files_full_paths.should == [
            File.join(@rails_dir, 'spec/javascripts/PlayerSpec.js'),
          ]
        end
      end

      it "should parse ERB" do
        @config.stub!(:simple_config_file).and_return(File.expand_path(File.join(File.dirname(__FILE__), 'fixture/jasmine.erb.yml')))
        Dir.stub!(:glob).and_return do |glob_string|
          glob_string
        end
        @config.src_files.should == [
          'file0.js',
          'file1.js',
          'file2.js',
          ]
      end


      describe "if sources.yaml not found" do
        before(:each) do
          File.stub!(:exist?).and_return(false)
        end
        it_should_behave_like "simple_config defaults"
      end

      describe "if jasmine.yml is empty" do
        before(:each) do
          @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))
          YAML.stub!(:load).and_return(false)
        end
        it_should_behave_like "simple_config defaults"

      end

#      describe "using default jasmine.yml" do
#        before(:each) do
#          @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))
#        end
#        it_should_behave_like "simple_config defaults"
#
#      end

      describe "should use the first appearance of duplicate filenames" do
        before(:each) do
          Dir.stub!(:glob).and_return do |glob_string|
            glob_string
          end
          fake_config = Hash.new.stub!(:[]).and_return(["file1.ext", "file2.ext", "file1.ext"])
          @config.stub!(:simple_config).and_return(fake_config)
        end

        it "src_files" do
          @config.src_files.should == ['file1.ext', 'file2.ext']
        end

        it "stylesheets" do
          @config.stylesheets.should == ['file1.ext', 'file2.ext']
        end

        it "spec_files" do
          @config.spec_files.should == ['file1.ext', 'file2.ext']
        end

        it "helpers" do
          @config.spec_files.should == ['file1.ext', 'file2.ext']
        end

        it "js_files" do
          @config.js_files.should == ["/file1.ext",
                                      "/file2.ext",
                                      "/__spec__/file1.ext",
                                      "/__spec__/file2.ext",
                                      "/__spec__/file1.ext",
                                      "/__spec__/file2.ext"]
        end

        it "spec_files_full_paths" do
          @config.spec_files_full_paths.should == [
              File.expand_path("spec/javascripts/file1.ext", @rails_dir),
              File.expand_path("spec/javascripts/file2.ext", @rails_dir)
          ]
        end

      end

      it "simple_config stylesheets" do
        @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))
        YAML.stub!(:load).and_return({'stylesheets' => ['foo.css', 'bar.css']})
        Dir.stub!(:glob).and_return do |glob_string|
          glob_string
        end
        @config.stylesheets.should == ['foo.css', 'bar.css']
      end


      it "using rails jasmine.yml" do
        @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine-rails.yml'))
        @config.spec_files.should == ['PlayerSpec.js']
        @config.helpers.should == ['helpers/SpecHelper.js']
        @config.src_files.should == ['public/javascripts/prototype.js',
                                     'public/javascripts/effects.js',
                                     'public/javascripts/controls.js',
                                     'public/javascripts/dragdrop.js',
                                     'public/javascripts/application.js',
                                     'public/javascripts/Player.js',
                                     'public/javascripts/Song.js']
        @config.js_files.should == [
          '/public/javascripts/prototype.js',
          '/public/javascripts/effects.js',
          '/public/javascripts/controls.js',
          '/public/javascripts/dragdrop.js',
          '/public/javascripts/application.js',
          '/public/javascripts/Player.js',
          '/public/javascripts/Song.js',
          '/__spec__/helpers/SpecHelper.js',
          '/__spec__/PlayerSpec.js',
        ]
        @config.js_files("PlayerSpec.js").should == [
          '/public/javascripts/prototype.js',
          '/public/javascripts/effects.js',
          '/public/javascripts/controls.js',
          '/public/javascripts/dragdrop.js',
          '/public/javascripts/application.js',
          '/public/javascripts/Player.js',
          '/public/javascripts/Song.js',
          '/__spec__/helpers/SpecHelper.js',
          '/__spec__/PlayerSpec.js'
        ]

      end

    end

  end

  describe "browser configuration" do
    it "should use firefox by default" do
      ENV.stub!(:[], "JASMINE_BROWSER").and_return(nil)
      config = Jasmine::Config.new
      config.stub!(:start_servers)
      Jasmine::SeleniumDriver.should_receive(:new).
        with(anything(), anything(), "*firefox", anything()).
        and_return(mock(Jasmine::SeleniumDriver, :connect => true))
      config.start
    end

    it "should use ENV['JASMINE_BROWSER'] if set" do
      ENV.stub!(:[], "JASMINE_BROWSER").and_return("mosaic")
      config = Jasmine::Config.new
      config.stub!(:start_servers)
      Jasmine::SeleniumDriver.should_receive(:new).
        with(anything(), anything(), "*mosaic", anything()).
        and_return(mock(Jasmine::SeleniumDriver, :connect => true))
      config.start
    end
  end

  describe "jasmine host" do
    it "should use http://localhost by default" do
      config = Jasmine::Config.new
      config.instance_variable_set(:@jasmine_server_port, '1234')
      config.stub!(:start_servers)

      Jasmine::SeleniumDriver.should_receive(:new).
        with(anything(), anything(), anything(), "http://localhost:1234/").
        and_return(mock(Jasmine::SeleniumDriver, :connect => true))
      config.start
    end

    it "should use ENV['JASMINE_HOST'] if set" do
      ENV.stub!(:[], "JASMINE_HOST").and_return("http://some_host")
      config = Jasmine::Config.new
      config.instance_variable_set(:@jasmine_server_port, '1234')
      config.stub!(:start_servers)

      Jasmine::SeleniumDriver.should_receive(:new).
        with(anything(), anything(), anything(), "http://some_host:1234/").
        and_return(mock(Jasmine::SeleniumDriver, :connect => true))
      config.start
    end
  end

  describe "#start_selenium_server" do
    it "should use an existing selenium server if SELENIUM_SERVER_PORT is set" do
      config = Jasmine::Config.new
      ENV.stub!(:[], "SELENIUM_SERVER_PORT").and_return(1234)
      Jasmine.should_receive(:wait_for_listener).with(1234, "selenium server")
      config.start_selenium_server
    end
  end
end

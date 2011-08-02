require "spec_helper"
require "rspec/core/rake_task"

module RSpec::Core
  describe RakeTask do
    let(:task) { RakeTask.new }

    before do
      File.stub(:exist?) { false }
    end

    def with_bundler
      task.skip_bundler = false
      File.stub(:exist?) { true }
      yield
    end

    def with_rcov
      task.rcov = true
      yield
    end

    def spec_command
      task.__send__(:spec_command)
    end

    context "default" do
      it "renders rspec" do
        spec_command.should =~ /^-S rspec/
      end
    end

    context "with bundler" do
      context "with Gemfile" do
        it "renders bundle exec rspec" do
          File.stub(:exist?) { true }
          task.skip_bundler = false
          spec_command.should match(/bundle exec/)
        end
      end

      context "with non-standard Gemfile" do
        it "renders bundle exec rspec" do
          File.stub(:exist?) {|f| f =~ /AltGemfile/}
          task.gemfile = 'AltGemfile'
          task.skip_bundler = false
          spec_command.should match(/bundle exec/)
        end
      end

      context "without Gemfile" do
        it "renders bundle exec rspec" do
          File.stub(:exist?) { false }
          task.skip_bundler = false
          spec_command.should_not match(/bundle exec/)
        end
      end
    end

    context "with rcov" do
      it "renders rcov" do
        with_rcov do
          spec_command.should =~ /^-S rcov/
        end
      end
    end

    context "with bundler and rcov" do
      it "renders bundle exec rcov" do
        with_bundler do
          with_rcov do
            spec_command.should =~ /^-S bundle exec rcov/
          end
        end
      end
    end

    context "with ruby options" do
      it "renders them before -S" do
        task.ruby_opts = "-w"
        spec_command.should =~ /^-w -S rspec/
      end
    end

    context "with rcov_opts" do
      context "with rcov=false (default)" do
        it "does not add the rcov options to the command" do
          task.rcov_opts = '--exclude "mocks"'
          spec_command.should_not =~ /--exclude "mocks"/
        end
      end

      context "with rcov=true" do
        it "renders them after rcov" do
          task.rcov = true
          task.rcov_opts = '--exclude "mocks"'
          spec_command.should =~ /rcov.*--exclude "mocks"/
        end

        it "ensures that -Ispec:lib is in the resulting command" do
          task.rcov = true
          task.rcov_opts = '--exclude "mocks"'
          spec_command.should =~ /rcov.*-Ispec:lib/
        end
      end
    end

    context "with rspec_opts" do
      context "with rcov=true" do
        it "adds the rspec_opts after the rcov_opts and files" do
          task.stub(:files_to_run) { "this.rb that.rb" }
          task.rcov = true
          task.rspec_opts = "-Ifoo"
          spec_command.should =~ /this.rb that.rb -- -Ifoo/
        end
      end
      context "with rcov=false (default)" do
        it "adds the rspec_opts" do
          task.rspec_opts = "-Ifoo"
          spec_command.should =~ /rspec -Ifoo/
        end
      end
    end

    context "with SPEC=path/to/file" do
      before do
        @orig_spec = ENV["SPEC"]
        ENV["SPEC"] = "path/to/file"
      end

      after do
        ENV["SPEC"] = @orig_spec
      end

      it "sets files to run" do
        task.__send__(:files_to_run).should eq(["path/to/file"])
      end
    end

    context "with paths with quotes" do
      before do
        @tmp_dir = File.expand_path('./tmp/rake_task_example/')
        FileUtils.mkdir_p @tmp_dir
        @task = RakeTask.new do |t|
          t.pattern = File.join(@tmp_dir, "*spec.rb")
        end
        ["first_spec.rb", "second_\"spec.rb", "third_\'spec.rb"].each do |file_name|
          FileUtils.touch(File.join(@tmp_dir, file_name))
        end
      end

      it "escapes the quotes" do
        @task.__send__(:files_to_run).sort.should eq([
          File.join(@tmp_dir, "first_spec.rb"),
          File.join(@tmp_dir, "second_\\\"spec.rb"),
          File.join(@tmp_dir, "third_\\\'spec.rb") 
        ])
      end
    end
  end
end

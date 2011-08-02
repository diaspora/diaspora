require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe "Jasmine command line tool" do
  before :each do
    temp_dir_before
    Dir::chdir @tmp
  end

  after :each do
    temp_dir_after
  end

  it "should create files on init" do
    output = capture_stdout { Jasmine::CommandLineTool.new.process ["init"] }
    output.should =~ /Jasmine has been installed with example specs./

    my_jasmine_lib = File.expand_path(File.join(@root, "lib"))
    bootstrap = "$:.unshift('#{my_jasmine_lib}')"

    ENV['JASMINE_GEM_PATH'] = "#{@root}/lib"
    ci_output = `rake -E "#{bootstrap}" --trace jasmine:ci`
    ci_output.should =~ (/[1-9][0-9]* examples, 0 failures/)
  end

  it "should include license info" do
    output = capture_stdout { Jasmine::CommandLineTool.new.process ["license"] }
    output.should =~ /Copyright/
  end
end
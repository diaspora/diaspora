require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe "Jasmine rails generator" do
  before :each do
    temp_dir_before
    Dir::chdir @tmp
  end

  after :each do
    temp_dir_after
  end

  it "should create files on init" do
    `rails rails-project`
    Dir::chdir 'rails-project'

    FileUtils.cp_r(File.join(@root, 'generators'), 'vendor')

    output = `./script/generate jasmine`
    output.should =~ /Jasmine has been installed with example specs./

    bootstrap = "$:.unshift('#{@root}/lib')"
    ENV['JASMINE_GEM_PATH'] = "#{@root}/lib"
    ci_output = `rake -E \"#{bootstrap}\" --trace jasmine:ci`
    ci_output.should =~ (/[1-9][0-9]* examples, 0 failures/)
  end
end
require File.join(File.dirname(__FILE__),"spec_helper.rb")
require 'stringio'
describe Launchy::Browser do
  it "should find a path to a executable" do
    begin
      File.executable?(Launchy::Browser.new.browser).should == true
    rescue => e
      e.message.should == "Unable to find browser to launch for os family 'nix'."
    end
  end

  it "should handle an http url" do
    Launchy::Browser.handle?("http://www.example.com").should == true
  end

  it "should handle an https url" do
    Launchy::Browser.handle?("https://www.example.com").should == true
  end

  it "should handle an ftp url" do
    Launchy::Browser.handle?("ftp://download.example.com").should == true
  end

  it "should not handle a mailto url" do
    Launchy::Browser.handle?("mailto:jeremy@example.com").should == false
  end

  it "creates a default unix application list" do
    begin
      Launchy::Browser.new.nix_app_list.class.should == Array
    rescue => e
      e.message.should == "Unable to find browser to launch for os family 'nix'."
    end
  end

  { "BROWSER" => "/bin/sh",
    "LAUNCHY_BROWSER" => "/bin/sh"}.each_pair do |e,v|
    it "can use environmental variable overrides of #{e} for the browser" do
      ENV[e] = v
      Launchy::Browser.new.browser.should eql(v)
      ENV[e] = nil
    end
  end

  it "reports when it cannot find an browser" do
    old_error = $stderr
    $stderr = StringIO.new
    ENV["LAUNCHY_HOST_OS"] = "testing"
    begin
      browser = Launchy::Browser.new
    rescue => e
      e.message.should =~ /Unable to find browser to launch for os family/m
    end
    ENV["LAUNCHY_HOST_OS"] = nil
    $stderr.string.should =~ /Unable to launch. No Browser application found./m
    $stderr = old_error
  end
end

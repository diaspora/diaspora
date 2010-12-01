require File.join(File.dirname(__FILE__),"spec_helper.rb")
require 'yaml'

describe Launchy::Application do
  before(:each) do
    yml = YAML::load(IO.read(File.join(File.dirname(__FILE__),"tattle-host-os.yml")))
    @host_os = yml['host_os']
    @app = Launchy::Application.new
  end

  YAML::load(IO.read(File.join(File.dirname(__FILE__), "tattle-host-os.yml")))['host_os'].keys.sort.each do |os|
    it "#{os} should be a found os" do
      Launchy::Application::known_os_families.should include(@app.my_os_family(os))
    end
  end

  it "should not find os of 'dos'" do
    @app.my_os_family('dos').should eql(:unknown)
  end

  it "my os should have a value" do
    @app.my_os.should_not eql('')
    @app.my_os.should_not eql(nil)
  end

  it "should find open or curl" do
    r = "found open or curl"
    found = %w[ open curl ].collect do |app|
      @app.find_executable(app).nil?
    end
    found.should be_include( false )
  end

  it "should not find app xyzzy" do
    @app.find_executable('xyzzy').should eql(nil)
  end

  it "should find the correct class to launch an ftp url" do
    Launchy::Application.find_application_class_for("ftp://ftp.ruby-lang.org/pub/ruby/").should == Launchy::Browser
  end

  it "knows when it cannot find an application class" do
    Launchy::Application.find_application_class_for("xyzzy:stuff,things").should == nil
  end

  it "allows for environmental override of host_os" do
    ENV["LAUNCHY_HOST_OS"] = "hal-9000"
    Launchy::Application.my_os.should eql("hal-9000")
    ENV["LAUNCHY_HOST_OS"] = nil
  end

  { "KDE_FULL_SESSION" => :kde,
    "KDE_SESSION_UID"  => :kde,
    "GNOME_DESKTOP_SESSION_ID" => :gnome }.each_pair do |k,v|
    it "can detect the desktop environment of a *nix machine using #{k}" do
      @app.nix_desktop_environment.should eql(:generic)
      ENV[k] = "launchy-test"
      Launchy::Application.new.nix_desktop_environment.should eql(v)
      ENV[k] = nil
    end
  end
end

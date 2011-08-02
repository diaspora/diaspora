require 'spec_helper'

describe Launchy::Detect::NixDesktopEnvironment do

  before do
    Launchy.reset_global_options
  end

  after do
    Launchy.reset_global_options
  end


  { "KDE_FULL_SESSION"         => Launchy::Detect::NixDesktopEnvironment::Kde,
    "GNOME_DESKTOP_SESSION_ID" => Launchy::Detect::NixDesktopEnvironment::Gnome }.each_pair do |k,v|
    it "can detect the desktop environment of a *nix machine using ENV[#{k}]" do
      ENV[k] = "launchy-test"
      nix_env = Launchy::Detect::NixDesktopEnvironment.detect
      nix_env.must_equal( v )
      nix_env.browser.must_equal( v.browser )
      ENV.delete( k )
    end
   end


  it "raises an error if it cannot determine the *nix desktop environment" do
    Launchy.host_os = "linux"
    ENV.delete( "KDE_FULL_SESSION" )
    ENV.delete( "GNOME_DESKTOP_SESSION_ID" )
    lambda { Launchy::Detect::NixDesktopEnvironment.detect }.must_raise Launchy::Detect::NixDesktopEnvironment::NotFoundError
  end
end

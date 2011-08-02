require 'spec_helper'

describe Launchy::Application::Browser do
  before do
    Launchy.reset_global_options
    ENV['KDE_FULL_SESSION'] = "launchy"
    @test_url = "http://example.com/"
  end

  after do
    Launchy.reset_global_options
    ENV.delete( 'KDE_FULL_SESSION' )
  end

  { 'windows' => 'start "Launchy" /d' ,
    'darwin'  => '/usr/bin/open',
    'cygwin'  => 'cmd /C start "Launchy" /d',

    # when running these tests on a linux box, this test will fail
    'linux'   => nil                 }.each  do |host_os, cmdline|
    it "when host_os is '#{host_os}' the appropriate 'app_list' method is called" do
      Launchy.host_os = host_os
      browser = Launchy::Application::Browser.new
      browser.app_list.first.must_equal cmdline
    end
  end

  %w[ linux windows darwin cygwin ].each do |host_os|
    it "the BROWSER environment variable overrides any host defaults on '#{host_os}'" do
      ENV['BROWSER'] = "my_special_browser --new-tab '%s'"
      Launchy.host_os = host_os
      browser = Launchy::Application::Browser.new
      cmd, args = browser.cmd_and_args( @test_url )
      cmd.must_equal "my_special_browser --new-tab 'http://example.com/'"
      args.must_equal []
    end
  end
end


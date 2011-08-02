require 'spec_helper'

describe Launchy::Detect::Runner do
  before do
    Launchy.reset_global_options
    @test_url = "http://example.com/?foo=bar&baz=wibble"
  end

  after do
    Launchy.reset_global_options
  end

  it "raises an error when there is an unknown host os" do
    Launchy.host_os = "foo"
    lambda{ Launchy::Detect::Runner.detect }.must_raise Launchy::Detect::HostOsFamily::NotFoundError
  end

  it "raises an error when there is an unknown ruby engine" do
    Launchy.ruby_engine = "wibble"
    lambda{ Launchy::Detect::Runner.detect }.must_raise Launchy::Detect::RubyEngine::NotFoundError
  end

  # On anything that has fork, use Forkable
  %w[ linux darwin cygwin ].each do |host_os|
    %w[ ruby rbx macruby ].each do |engine_name|
      it "engine '#{engine_name}' on OS '#{host_os}' uses runner Forkable" do
        Launchy.host_os = host_os
        Launchy.ruby_engine = engine_name
        engine = Launchy::Detect::Runner.detect
        engine.must_be_instance_of Launchy::Detect::Runner::Forkable
      end
    end
  end


  # Jruby always uses the Jruby runner except on Windows
  { 'mingw'  => Launchy::Detect::Runner::Windows,
    'linux'  => Launchy::Detect::Runner::Jruby,
    'darwin' => Launchy::Detect::Runner::Jruby,
    'cygwin' => Launchy::Detect::Runner::Jruby, }.each_pair do |host_os, runner|
    it "engine 'jruby' on OS '#{host_os}' uses runner #{runner.name}" do
      Launchy.host_os = host_os
      Launchy.ruby_engine = 'jruby'
      engine = Launchy::Detect::Runner.detect
      engine.must_be_instance_of runner
    end
  end

  # If you are on windows, no matter what engine, you use the windows runner
  %w[ ruby rbx jruby macruby ].each do |engine_name|
    it "uses a Windows runner when the engine is '#{engine_name}'" do
      Launchy.host_os = "mingw"
      Launchy.ruby_engine = engine_name
      e = Launchy::Detect::Runner.detect
      e.must_be_instance_of Launchy::Detect::Runner::Windows
    end
  end

  it "Windows launches use the 'cmd' command" do
    win = Launchy::Detect::Runner::Windows.new
    cmd = win.dry_run( "not-really", [ "http://example.com" ] )
    cmd.must_equal 'cmd /c not-really http://example.com'
  end

  it "Windows escapes '&' in urls" do
    win = Launchy::Detect::Runner::Windows.new
    win.all_args( "not-really", [ @test_url ] ).must_equal [ 'cmd', '/c', 'not-really', 'http://example.com/?foo=bar^&baz=wibble' ]

    cmd = win.dry_run( "not-really", [ @test_url ] )
    cmd.must_equal 'cmd /c not-really http://example.com/?foo=bar^&baz=wibble'
  end

  it "Jruby escapes '&' in urls" do
    jruby = Launchy::Detect::Runner::Jruby.new
    cmd = jruby.dry_run( "not-really", [ @test_url ])
    cmd.must_equal 'not-really http://example.com/\\?foo\\=bar\\&baz\\=wibble'
  end

end

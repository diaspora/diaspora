require File.dirname(__FILE__) + '/../spec_helper'

class Server::WebrickAdapter; def start; end end

describe YARD::CLI::Server do
  before do
    @no_verify_libraries = false
    @no_adapter_mock = false
    @libraries = {}
    @options = {:single_library => true, :caching => false}
    @server_options = {:Port => 8808}
    @adapter = mock(:adapter)
    @adapter.stub!(:setup)
    @cli = YARD::CLI::Server.new
  end
  
  def rack_required
    begin; require 'rack'; rescue LoadError; pending "rack required for this test" end
  end
  
  def unstub_adapter
    @no_adapter_mock = true
  end
  
  def run(*args)
    if @libraries.empty?
      library = Server::LibraryVersion.new(File.basename(Dir.pwd), nil, File.expand_path('.yardoc'))
      @libraries = {library.name => [library]}
    end
    unless @no_verify_libraries
      @libraries.values.each {|libs| libs.each {|lib| File.should_receive(:exist?).at_least(1).times.with(File.expand_path(lib.yardoc_file)).and_return(true) } }
    end
    unless @no_adapter_mock
      @cli.stub!(:adapter).and_return(@adapter)
      @adapter.should_receive(:new).with(@libraries, @options, @server_options).and_return(@adapter)
      @adapter.should_receive(:start)
    end
    @cli.run(*args.flatten)
  end

  it "should default to current dir if no library is specified" do
    Dir.should_receive(:pwd).and_return('/path/to/foo')
    @libraries['foo'] = [Server::LibraryVersion.new('foo', nil, File.expand_path('.yardoc'))]
    run
  end
  
  it "should use .yardoc as yardoc file is library list is odd" do
    @libraries['a'] = [Server::LibraryVersion.new('a', nil, File.expand_path('.yardoc'))]
    run 'a'
  end
  
  it "should force multi library if more than one library is listed" do
    @options[:single_library] = false
    @libraries['a'] = [Server::LibraryVersion.new('a', nil, File.expand_path('b'))]
    @libraries['c'] = [Server::LibraryVersion.new('c', nil, File.expand_path('.yardoc'))]
    run %w(a b c)
  end
  
  it "should accept -m, --multi-library" do
    @options[:single_library] = false
    run '-m'
    run '--multi-library'
  end
  
  it "should accept -c, --cache" do
    @options[:caching] = true
    run '-c'
    run '--cache'
  end
  
  it "should accept -r, --reload" do
    @options[:incremental] = true
    run '-r'
    run '--reload'
  end
  
  it "should accept -d, --daemon" do
    @server_options[:daemonize] = true
    run '-d'
    run '--daemon'
  end
  
  it "should accept -p, --port" do
    @server_options[:Port] = 10
    run '-p', '10'
    run '--port', '10'
  end
  
  it "should accept --docroot" do
    @server_options[:DocumentRoot] = '/foo/bar'
    run '--docroot', '/foo/bar'
  end
  
  it "should accept -a webrick to create WEBrick adapter" do
    @cli.should_receive(:adapter=).with(YARD::Server::WebrickAdapter)
    run '-a', 'webrick'
  end
  
  it "should accept -a rack to create Rack adapter" do
    rack_required
    @cli.should_receive(:adapter=).with(YARD::Server::RackAdapter)
    run '-a', 'rack'
  end
  
  it "should default to Rack adapter if exists on system" do
    rack_required
    @cli.should_receive(:require).with('rubygems').and_return(false)
    @cli.should_receive(:require).with('rack').and_return(true)
    @cli.should_receive(:adapter=).with(YARD::Server::RackAdapter)
    @cli.send(:select_adapter)
  end

  it "should fall back to WEBrick adapter if Rack is not on system" do
    @cli.should_receive(:require).with('rubygems').and_return(false)
    @cli.should_receive(:require).with('rack').and_raise(LoadError)
    @cli.should_receive(:adapter=).with(YARD::Server::WebrickAdapter)
    @cli.send(:select_adapter)
  end
  
  it "should accept -s, --server" do
    @server_options[:server] = 'thin'
    run '-s', 'thin'
    run '--server', 'thin'
  end
  
  it "should accept -g, --gems" do
    @no_verify_libraries = true
    @options[:single_library] = false
    @libraries['gem1'] = [Server::LibraryVersion.new('gem1', '1.0.0', nil, :gem)]
    @libraries['gem2'] = [Server::LibraryVersion.new('gem2', '1.0.0', nil, :gem)]
    gem1 = mock(:gem1)
    gem1.stub!(:name).and_return('gem1')
    gem1.stub!(:version).and_return('1.0.0')
    gem1.stub!(:full_gem_path).and_return('/path/to/foo')
    gem2 = mock(:gem2)
    gem2.stub!(:name).and_return('gem2')
    gem2.stub!(:version).and_return('1.0.0')
    gem2.stub!(:full_gem_path).and_return('/path/to/bar')
    specs = {'gem1' => gem1, 'gem2' => gem2}
    source = mock(:source_index)
    source.stub!(:find_name).and_return do |k, ver|
      k == '' ? specs.values : specs.grep(k).map {|name| specs[name] }
    end
    Gem.stub!(:source_index).and_return(source)
    run '-g'
    run '--gems'
  end
  
  it "should load template paths after adapter template paths" do
    unstub_adapter
    @cli.adapter = Server::WebrickAdapter
    run '-t', 'foo'
    Templates::Engine.template_paths.last.should == 'foo'
  end
  
  it "should load ruby code (-e) after adapter" do
    unstub_adapter
    @cli.adapter = Server::WebrickAdapter
    File.open(File.dirname(__FILE__) + '/tmp.adapterscript.rb', 'w') do |f|
      begin
        f.puts "YARD::Templates::Engine.register_template_path 'foo'"
        f.flush
        run '-e', f.path
        Templates::Engine.template_paths.last.should == 'foo'
      ensure
        File.unlink(f.path)
      end
    end
  end
end

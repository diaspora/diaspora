require File.join(File.dirname(__FILE__), "spec_helper")

require 'yaml'

describe YARD::Config do
  describe '.load' do
    before do
      File.should_receive(:file?).with(CLI::Yardoc::DEFAULT_YARDOPTS_FILE).and_return(false)
    end

    it "should use default options if no ~/.yard/config is found" do
      File.should_receive(:file?).with(YARD::Config::IGNORED_PLUGINS).and_return(false)
      File.should_receive(:file?).with(YARD::Config::CONFIG_FILE).and_return(false)
      YARD::Config.load
      YARD::Config.options.should == YARD::Config::DEFAULT_CONFIG_OPTIONS
    end
    
    it "should overwrite options with data in ~/.yard/config" do
      File.should_receive(:file?).with(YARD::Config::CONFIG_FILE).and_return(true)
      File.should_receive(:file?).with(YARD::Config::IGNORED_PLUGINS).and_return(false)
      YAML.should_receive(:load_file).with(YARD::Config::CONFIG_FILE).and_return({'test' => true})
      YARD::Config.load
      YARD::Config.options[:test].should be_true
    end
    
    it "should ignore any plugins specified in '~/.yard/ignored_plugins'" do
      File.should_receive(:file?).with(YARD::Config::CONFIG_FILE).and_return(false)
      File.should_receive(:file?).with(YARD::Config::IGNORED_PLUGINS).and_return(true)
      File.should_receive(:read).with(YARD::Config::IGNORED_PLUGINS).and_return('yard-plugin plugin2')
      YARD::Config.load
      YARD::Config.options[:ignored_plugins].should == ['yard-plugin', 'yard-plugin2']
      YARD::Config.should_not_receive(:require).with('yard-plugin2')
      YARD::Config.load_plugin('yard-plugin2').should == false
    end
  end
  
  describe '.save' do
    it "should save options to config file" do
      YARD::Config.stub!(:options).and_return(:a => 1, :b => %w(a b c))
      file = mock(:file)
      File.should_receive(:open).with(YARD::Config::CONFIG_FILE, 'w').and_yield(file)
      file.should_receive(:write).with(YAML.dump(:a => 1, :b => %w(a b c)))
      YARD::Config.save
    end
  end
  
  describe '.load_plugin' do
    it "should load a plugin by 'name' as 'yard-name'" do
      YARD::Config.should_receive(:require).with('yard-foo')
      log.should_receive(:debug).with(/Loading plugin 'yard-foo'/).once
      YARD::Config.load_plugin('foo').should == true
    end
    
    it "should not load plugins like 'doc-*'" do
      YARD::Config.should_not_receive(:require).with('yard-doc-core')
      YARD::Config.load_plugin('doc-core')
      YARD::Config.load_plugin('yard-doc-core')
    end
    
    it "should load plugin by 'yard-name' as 'yard-name'" do
      YARD::Config.should_receive(:require).with('yard-foo')
      log.should_receive(:debug).with(/Loading plugin 'yard-foo'/).once
      YARD::Config.load_plugin('yard-foo').should == true
    end
    
    it "should load plugin by 'yard_name' as 'yard_name'" do
      YARD::Config.should_receive(:require).with('yard_foo')
      log.should_receive(:debug).with(/Loading plugin 'yard_foo'/).once
      log.show_backtraces = false
      YARD::Config.load_plugin('yard_foo').should == true
    end
    
    it "should log error if plugin is not found" do
      YARD::Config.should_receive(:require).with('yard-foo').and_raise(LoadError)
      log.should_receive(:warn).with(/Error loading plugin 'yard-foo'/).once
      YARD::Config.load_plugin('yard-foo').should == false
    end
    
    it "should sanitize plugin name (remove /'s)" do
      YARD::Config.should_receive(:require).with('yard-foofoo')
      YARD::Config.load_plugin('foo/foo').should == true
    end
    
    it "should ignore plugins in :ignore_plugins" do
      YARD::Config.stub!(:options).and_return(:ignored_plugins => ['yard-foo', 'yard-bar'])
      YARD::Config.load_plugin('foo').should == false
      YARD::Config.load_plugin('bar').should == false
    end
  end
  
  describe '.load_plugins' do
    it "should load gem plugins if :load_plugins is true" do
      File.should_receive(:file?).with(CLI::Yardoc::DEFAULT_YARDOPTS_FILE).and_return(false)
      YARD::Config.stub!(:options).and_return(:load_plugins => true, :ignored_plugins => [], :autoload_plugins => [])
      YARD::Config.stub!(:load_plugin)
      YARD::Config.should_receive(:require).with('rubygems')
      YARD::Config.load_plugins
    end
    
    it "should ignore gem loading if RubyGems cannot load" do
      YARD::Config.stub!(:options).and_return(:load_plugins => true, :ignored_plugins => [], :autoload_plugins => [])
      YARD::Config.should_receive(:require).with('rubygems').and_raise(LoadError)
      YARD::Config.load_plugins.should == false
    end
    
    it "should load certain plugins automatically when specified in :autoload_plugins" do
      File.should_receive(:file?).with(CLI::Yardoc::DEFAULT_YARDOPTS_FILE).and_return(false)
      YARD::Config.stub!(:options).and_return(:load_plugins => false, :ignored_plugins => [], :autoload_plugins => ['yard-plugin'])
      YARD::Config.should_receive(:require).with('yard-plugin').and_return(true)
      YARD::Config.load_plugins.should == true
    end
    
    it "should parse --plugin from command line arguments" do
      YARD::Config.should_receive(:arguments).at_least(1).times.and_return(%w(--plugin foo --plugin bar a b c))
      YARD::Config.should_receive(:load_plugin).with('foo').and_return(true)
      YARD::Config.should_receive(:load_plugin).with('bar').and_return(true)
      YARD::Config.load_plugins.should == true
    end
    
    it "should load --plugin arguments from .yardopts" do
      File.should_receive(:file?).with(CLI::Yardoc::DEFAULT_YARDOPTS_FILE).once.and_return(true)
      File.should_receive(:file?).with(YARD::Config::CONFIG_FILE).and_return(false)
      File.should_receive(:file?).with(YARD::Config::IGNORED_PLUGINS).and_return(false)
      File.should_receive(:read_binary).with(CLI::Yardoc::DEFAULT_YARDOPTS_FILE).once.and_return('--plugin foo')
      YARD::Config.should_receive(:load_plugin).with('foo')
      YARD::Config.load
    end
    
    it "should load any gem plugins starting with 'yard_' or 'yard-'" do
      File.should_receive(:file?).with(CLI::Yardoc::DEFAULT_YARDOPTS_FILE).and_return(false)
      YARD::Config.stub!(:options).and_return(:load_plugins => true, :ignored_plugins => ['yard_plugin'], :autoload_plugins => [])
      plugins = {
        'yard' => mock('yard'), 
        'yard_plugin' => mock('yard_plugin'), 
        'yard-plugin' => mock('yard-plugin'),
        'my-yard-plugin' => mock('yard-plugin'),
        'rspec' => mock('rspec'),
      }
      plugins.each do |k, v|
        v.should_receive(:name).at_least(1).times.and_return(k)
      end
      
      source_mock = mock(:source_index)
      source_mock.should_receive(:find_name).with('').and_return(plugins.values)
      Gem.should_receive(:source_index).and_return(source_mock)
      YARD::Config.should_receive(:load_plugin).with('yard_plugin').and_return(false)
      YARD::Config.should_receive(:load_plugin).with('yard-plugin').and_return(true)
      YARD::Config.load_plugins.should == true
    end
    
    it "should log an error if a gem raises an error" do
      YARD::Config.stub!(:options).and_return(:load_plugins => true, :ignored_plugins => [], :autoload_plugins => [])
      plugins = {
        'yard-plugin' => mock('yard-plugin')
      }
      plugins.each do |k, v|
        v.should_receive(:name).at_least(1).times.and_return(k)
      end
      
      source_mock = mock(:source_index)
      source_mock.should_receive(:find_name).with('').and_return(plugins.values)
      Gem.should_receive(:source_index).and_return(source_mock)
      YARD::Config.should_receive(:load_plugin).with('yard-plugin').and_raise(Gem::LoadError)
      log.should_receive(:warn).with(/Error loading plugin 'yard-plugin'/)
      YARD::Config.load_plugins.should == false
    end
  end
end
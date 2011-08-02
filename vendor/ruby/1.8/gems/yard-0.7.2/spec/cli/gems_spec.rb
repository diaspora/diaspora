require File.dirname(__FILE__) + '/../spec_helper'
require 'ostruct'
require 'rubygems'

describe YARD::CLI::Gems do
  before do
    @rebuild = false
    @gem1 = build_mock('gem1')
    @gem2 = build_mock('gem2')
    @gem3 = build_mock('gem3')
  end
  
  def build_mock(name, version = '1.0')
    OpenStruct.new  :name => name, 
                    :version => version, 
                    :full_gem_path => "/path/to/gems/#{name}-#{version}", 
                    :yardoc_file => "/path/to/yardoc/#{name}-#{version}"
  end
  
  def build_specs(*specs)
    specs.each do |themock|
      Registry.should_receive(:yardoc_file_for_gem).with(themock.name, "= #{themock.version}").and_return(themock.yardoc_file)
      File.should_receive(:directory?).with(themock.yardoc_file).and_return(@rebuild)
      File.should_receive(:directory?).with(themock.full_gem_path).and_return(true)
      Registry.should_receive(:yardoc_file_for_gem).with(themock.name, "= #{themock.version}", true).and_return(themock.yardoc_file)
      Dir.should_receive(:chdir).with(themock.full_gem_path)
    end
    Registry.should_receive(:clear).exactly(specs.size).times
    CLI::Yardoc.should_receive(:run).exactly(specs.size).times
  end
  
  describe '#run' do
    it "should build all gem indexes if no gem is specified" do
      build_specs(@gem1, @gem2)
      Gem.source_index.should_receive(:find_name).with('').and_return([@gem1, @gem2])
      CLI::Gems.run
    end
    
    it "should allow gem to be specified" do
      build_specs(@gem1)
      Gem.source_index.should_receive(:find_name).with(@gem1.name, '>= 0').and_return([@gem1])
      CLI::Gems.run(@gem1.name)
    end
    
    it "should allow multiple gems to be specified for building" do
      build_specs(@gem1, @gem2)
      Gem.source_index.should_receive(:find_name).with(@gem1.name, @gem1.version).and_return([@gem1])
      Gem.source_index.should_receive(:find_name).with(@gem2.name, '>= 0').and_return([@gem2])
      CLI::Gems.run(@gem1.name, @gem1.version, @gem2.name)
    end
    
    it "should allow version to be specified with gem" do
      build_specs(@gem1)
      Gem.source_index.should_receive(:find_name).with(@gem1.name, '>= 1.0').and_return([@gem1])
      CLI::Gems.run(@gem1.name, '>= 1.0')
    end
    
    it "should warn if one of the gems is not found, but it should process others" do
      build_specs(@gem2)
      Gem.source_index.should_receive(:find_name).with(@gem1.name, '>= 2.0').and_return([])
      Gem.source_index.should_receive(:find_name).with(@gem2.name, '>= 0').and_return([@gem2])
      log.should_receive(:warn).with(/#{@gem1.name} >= 2.0 could not be found/)
      CLI::Gems.run(@gem1.name, '>= 2.0', @gem2.name)
    end
    
    it "should fail if specified gem(s) is/are not found" do
      CLI::Yardoc.should_not_receive(:run)
      Gem.source_index.should_receive(:find_name).with(@gem1.name, '>= 2.0').and_return([])
      log.should_receive(:warn).with(/#{@gem1.name} >= 2.0 could not be found/)
      log.should_receive(:error).with(/No specified gems could be found/)
      CLI::Gems.run(@gem1.name, '>= 2.0')
    end
    
    it "should accept --rebuild" do
      @rebuild = true
      build_specs(@gem1)
      Gem.source_index.should_receive(:find_name).with('').and_return([@gem1])
      CLI::Gems.run('--rebuild')
    end
  end
end

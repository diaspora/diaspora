require File.dirname(__FILE__) + '/../spec_helper'
require 'stringio'
require 'open-uri'

describe YARD::CLI::Diff do
  before do
    CLI::Yardoc.stub!(:run)
    CLI::Gems.stub!(:run)
    @diff = CLI::Diff.new
  end
  
  describe 'Argument handling' do
    it "should exit if there is only one gem name" do
      @diff.should_receive(:exit)
      @diff.should_receive(:puts).with(/Usage/)
      @diff.run
    end
  end
  
  describe 'Diffing' do
    before do
      @objects1 = nil
      @objects2 = nil
    end

    def run(*args)
      @data = StringIO.new
      @objects1 ||= %w( C#fooey C#baz D.bar )
      @objects2 ||= %w( A A::B A::B::C A.foo A#foo B C.foo C.bar C#baz )
      @diff.should_receive(:load_gem_data).ordered.with('gem1').and_return(true)
      @diff.should_receive(:load_gem_data).ordered.with('gem2').and_return(true)
      Registry.should_receive(:all).ordered.and_return(@objects1.map {|o| P(o) })
      Registry.should_receive(:all).ordered.and_return(@objects2.map {|o| P(o) })
      @diff.stub!(:print) {|data| @data << data }
      @diff.stub!(:puts) {|*args| @data << args.join("\n"); @data << "\n" }
      @diff.run(*(args + ['gem1', 'gem2']))
    end

    it "should show differences between objects" do
      run
      @data.string.should == <<-eof
Added objects:

  A (...)
  B
  C.bar
  C.foo

Removed objects:

  C#fooey
  D.bar

eof
    end

    it "should accept -a/--all" do
      ['-a', '--all'].each do |opt|
        run(opt)
        @data.string.should == <<-eof
Added objects:

  A
  A#foo
  A.foo
  A::B
  A::B::C
  B
  C.bar
  C.foo

Removed objects:

  C#fooey
  D.bar

eof
      end
    end
  end
  
  describe 'File searching' do
    before do
      @diff.stub!(:generate_yardoc)
    end
    
    it "should search for gem/.yardoc" do
      File.should_receive(:directory?).with('gem1/.yardoc').and_return(true)
      File.should_receive(:directory?).with('gem2/.yardoc').and_return(true)
      Registry.should_receive(:load_yardoc).with('gem1/.yardoc')
      Registry.should_receive(:load_yardoc).with('gem2/.yardoc')
      @diff.run('gem1', 'gem2')
    end
    
    it "should search for argument as yardoc" do
      File.should_receive(:directory?).with('gem1/.yardoc').and_return(false)
      File.should_receive(:directory?).with('gem2/.yardoc').and_return(false)
      File.should_receive(:directory?).with('gem1').and_return(true)
      File.should_receive(:directory?).with('gem2').and_return(true)
      Registry.should_receive(:load_yardoc).with('gem1')
      Registry.should_receive(:load_yardoc).with('gem2')
      @diff.run('gem1', 'gem2')
    end

    it "should search for installed gem" do
      File.should_receive(:directory?).with('gem1-1.0.0.gem/.yardoc').and_return(false)
      File.should_receive(:directory?).with('gem2-1.0.0/.yardoc').and_return(false)
      File.should_receive(:directory?).with('gem1-1.0.0.gem').and_return(false)
      File.should_receive(:directory?).with('gem2-1.0.0').and_return(false)
      gemmock = mock(:gemmock)
      spec1 = mock(:spec)
      spec2 = mock(:spec)
      gemmock.should_receive(:find_name).at_least(1).times.and_return([spec1, spec2])
      Gem.should_receive(:source_index).at_least(1).times.and_return(gemmock)
      spec1.stub!(:full_name).and_return('gem1-1.0.0')
      spec1.stub!(:name).and_return('gem1')
      spec1.stub!(:version).and_return('1.0.0')
      spec2.stub!(:full_name).and_return('gem2-1.0.0')
      spec2.stub!(:name).and_return('gem2')
      spec2.stub!(:version).and_return('1.0.0')
      Registry.should_receive(:yardoc_file_for_gem).with('gem1', '= 1.0.0').and_return('/path/to/file')
      Registry.should_receive(:yardoc_file_for_gem).with('gem2', '= 1.0.0').and_return(nil)
      Registry.should_receive(:load_yardoc).with('/path/to/file')
      CLI::Gems.should_receive(:run).with('gem2', '1.0.0').and_return(nil)
      Dir.stub!(:chdir)
      @diff.run('gem1-1.0.0.gem', 'gem2-1.0.0')
    end
    
    it "should search for .gem file" do
      iomock = mock(:io)
      File.should_receive(:directory?).with('gem1/.yardoc').and_return(false)
      File.should_receive(:directory?).with('gem2.gem/.yardoc').and_return(false)
      File.should_receive(:directory?).with('gem1').and_return(false)
      File.should_receive(:directory?).with('gem2.gem').and_return(false)
      File.should_receive(:directory?).any_number_of_times
      File.should_receive(:exist?).with('gem1.gem').and_return(true)
      File.should_receive(:exist?).with('gem2.gem').and_return(true)
      File.should_receive(:exist?).any_number_of_times
      File.should_receive(:open).with('gem1.gem', 'rb').and_yield(iomock)
      File.should_receive(:open).with('gem2.gem', 'rb')
      FileUtils.should_receive(:mkdir_p)
      Gem::Package.should_receive(:open).with(iomock)
      FileUtils.should_receive(:rm_rf)
      @diff.run('gem1', 'gem2.gem')
    end
    
    it "should search for .gem file on rubygems.org" do
      iomock = mock(:io)
      File.should_receive(:directory?).with('gem1/.yardoc').and_return(false)
      File.should_receive(:directory?).with('gem2.gem/.yardoc').and_return(false)
      File.should_receive(:directory?).with('gem1').and_return(false)
      File.should_receive(:directory?).with('gem2.gem').and_return(false)
      File.should_receive(:directory?).any_number_of_times
      File.should_receive(:exist?).with('gem1.gem').and_return(false)
      File.should_receive(:exist?).with('gem2.gem').and_return(false)
      File.should_receive(:exist?).any_number_of_times
      @diff.should_receive(:open).with('http://rubygems.org/downloads/gem1.gem').and_yield(iomock)
      @diff.should_receive(:open).with('http://rubygems.org/downloads/gem2.gem')
      FileUtils.should_receive(:mkdir_p)
      Gem::Package.should_receive(:open).with(iomock)
      FileUtils.should_receive(:rm_rf)
      @diff.run('gem1', 'gem2.gem')
    end
    
    it "should error if gem is not found" do
      log.should_receive(:error).with("Cannot find gem gem1")
      log.should_receive(:error).with("Cannot find gem gem2.gem")
      @diff.stub!(:load_gem_data).and_return(false)
      @diff.run('gem1', 'gem2.gem')
    end
  end
end
require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::CLI::Yardoc do
  before do
    @yardoc = YARD::CLI::Yardoc.new
    @yardoc.statistics = false
    @yardoc.use_document_file = false
    @yardoc.use_yardopts_file = false
    @yardoc.generate = false
    Templates::Engine.stub!(:render)
    Templates::Engine.stub!(:generate)
    YARD.stub!(:parse)
  end
  
  describe 'Defaults' do
    before do
      @yardoc = CLI::Yardoc.new
      @yardoc.stub!(:yardopts).and_return([])
      @yardoc.stub!(:support_rdoc_document_file!).and_return([])
      @yardoc.parse_arguments
    end
    
    it "should use cache by default" do
      @yardoc.use_cache.should == false
    end
    
    it "print statistics by default" do
      @yardoc.statistics.should == true
    end
    
    it "should generate output by default" do
      @yardoc.generate.should == true
    end
    
    it "should read .yardopts by default" do
      @yardoc.use_yardopts_file.should == true
    end
    
    it "should read .document by default" do
      @yardoc.use_document_file.should == true
    end
    
    it "should use {lib,app}/**/*.rb and ext/**/*.c as default file glob" do
      @yardoc.files.should == ['{lib,app}/**/*.rb', 'ext/**/*.c']
    end
    
    it "should use rdoc as default markup type (but falls back on none)" do
      @yardoc.options[:markup].should == :rdoc
    end
    
    it "should use default as default template" do
      @yardoc.options[:template].should == :default
    end
    
    it "should use HTML as default format" do
      @yardoc.options[:format].should == :html
    end
    
    it "should use 'Object' as default return type" do
      @yardoc.options[:default_return].should == 'Object'
    end
    
    it "should not hide void return types by default" do
      @yardoc.options[:hide_void_return].should == false
    end
    
    it "should only show public visibility by default" do
      @yardoc.visibilities.should == [:public]
    end
    
    it "should not list objects by default" do
      @yardoc.list.should == false
    end
  end
  
  describe 'General options' do
    def self.should_accept(*args, &block)
      @counter ||= 0
      @counter += 1
      counter = @counter
      args.each do |arg| 
        define_method("test_options_#{@counter}", &block)
        it("should accept #{arg}") { send("test_options_#{counter}", arg) }
      end
    end
    
    should_accept('--single-db') do |arg|
      @yardoc.parse_arguments(arg)
      Registry.single_object_db.should == true
      Registry.single_object_db = nil
    end

    should_accept('--no-single-db') do |arg|
      @yardoc.parse_arguments(arg)
      Registry.single_object_db.should == false
      Registry.single_object_db = nil
    end
    
    should_accept('-c', '--use-cache') do |arg|
      @yardoc.parse_arguments(arg)
      @yardoc.use_cache.should == true
    end
    
    should_accept('--no-cache') do |arg|
      @yardoc.parse_arguments(arg)
      @yardoc.use_cache.should == false
    end
    
    should_accept('--yardopts') do |arg|
      @yardoc = CLI::Yardoc.new
      @yardoc.use_document_file = false
      @yardoc.should_receive(:yardopts).at_least(1).times.and_return([])
      @yardoc.parse_arguments(arg)
      @yardoc.use_yardopts_file.should == true
      @yardoc.parse_arguments('--no-yardopts', arg)
      @yardoc.use_yardopts_file.should == true
    end

    should_accept('--yardopts with filename') do |arg|
      @yardoc = CLI::Yardoc.new
      File.should_receive(:read_binary).with('.foobar').and_return('')
      @yardoc.use_document_file = false
      @yardoc.parse_arguments('--yardopts', '.foobar')
      @yardoc.use_yardopts_file.should == true
      @yardoc.options_file.should == '.foobar'
    end

    should_accept('--no-yardopts') do |arg|
      @yardoc = CLI::Yardoc.new
      @yardoc.use_document_file = false
      @yardoc.should_not_receive(:yardopts)
      @yardoc.parse_arguments(arg)
      @yardoc.use_yardopts_file.should == false
      @yardoc.parse_arguments('--yardopts', arg)
      @yardoc.use_yardopts_file.should == false
    end

    should_accept('--document') do |arg|
      @yardoc = CLI::Yardoc.new
      @yardoc.use_yardopts_file = false
      @yardoc.should_receive(:support_rdoc_document_file!).and_return([])
      @yardoc.parse_arguments('--no-document', arg)
      @yardoc.use_document_file.should == true
    end

    should_accept('--no-document') do |arg|
      @yardoc = CLI::Yardoc.new
      @yardoc.use_yardopts_file = false
      @yardoc.should_not_receive(:support_rdoc_document_file!)
      @yardoc.parse_arguments('--document', arg)
      @yardoc.use_document_file.should == false
    end
    
    should_accept('-b', '--db') do |arg|
      @yardoc.parse_arguments(arg, 'test')
      Registry.yardoc_file.should == 'test'
      Registry.yardoc_file = '.yardoc'
    end
    
    should_accept('-n', '--no-output') do |arg|
      Templates::Engine.should_not_receive(:generate)
      @yardoc.run(arg)
    end
        
    should_accept('--exclude') do |arg|
      YARD.should_receive(:parse).with(['a'], ['nota', 'b'])
      @yardoc.run(arg, 'nota', arg, 'b', 'a')
    end
    
    should_accept('--no-save') do |arg|
      YARD.should_receive(:parse)
      Registry.should_not_receive(:save)
      @yardoc.run(arg)
    end
  end
  
  describe 'Output options' do
    it "should accept --title" do
      @yardoc.parse_arguments('--title', 'hello world')
      @yardoc.options[:title].should == 'hello world'
    end

    it "should allow --title to have multiple spaces in .yardopts" do
      File.should_receive(:read_binary).with("test").and_return("--title \"Foo Bar\"")
      @yardoc.options_file = "test"
      @yardoc.use_yardopts_file = true
      @yardoc.run
      @yardoc.options[:title].should == "Foo Bar"
    end

    it "should alias --main to the --readme flag" do
      readme = File.join(File.dirname(__FILE__),'..','..','README.md')

      @yardoc.parse_arguments('--main', readme)
      @yardoc.options[:readme].should == CodeObjects::ExtraFileObject.new(readme, '')
    end

    it "should select a markup provider when --markup-provider or -mp is set" do
      @yardoc.parse_arguments("-M", "test")
      @yardoc.options[:markup_provider].should == :test
      @yardoc.parse_arguments("--markup-provider", "test2")
      @yardoc.options[:markup_provider].should == :test2
    end
    
    it "should select a markup format when -m is set" do
      @yardoc.should_receive(:verify_markup_options).and_return(true)
      @yardoc.generate = true
      @yardoc.parse_arguments('-m', 'markdown')
      @yardoc.options[:markup].should == :markdown
    end

    it "should accept --default-return" do
      @yardoc.parse_arguments *%w( --default-return XYZ )
      @yardoc.options[:default_return].should == "XYZ"
    end

    it "should allow --hide-void-return to be set" do
      @yardoc.parse_arguments *%w( --hide-void-return )
      @yardoc.options[:hide_void_return].should be_true
    end

    it "should generate all objects with --use-cache" do
      YARD.should_receive(:parse)
      Registry.should_receive(:load)
      Registry.should_receive(:load_all)
      @yardoc.stub!(:generate).and_return(true)
      @yardoc.run *%w( --use-cache )
    end

    it "should not print statistics with --no-stats" do
      @yardoc.stub!(:statistics).and_return(false)
      CLI::Stats.should_not_receive(:new)
      @yardoc.run *%w( --no-stats )
    end
    
    describe '--asset' do
      before do
        @yardoc.generate = true
        @yardoc.stub!(:run_generate)
      end
      
      it "should copy assets to output directory" do
        FileUtils.should_receive(:cp_r).with('a', 'doc/a')
        @yardoc.run *%w( --asset a )
        @yardoc.assets.should == {'a' => 'a'}
      end

      it "should allow multiple --asset options" do
        FileUtils.should_receive(:cp_r).with('a', 'doc/a')
        FileUtils.should_receive(:cp_r).with('b', 'doc/b')
        @yardoc.run *%w( --asset a --asset b )
        @yardoc.assets.should == {'a' => 'a', 'b' => 'b'}
      end

      it "should not allow from or to to refer to a path above current path" do
        log.should_receive(:warn).exactly(4).times.with(/invalid/i)
        @yardoc.run *%w( --asset ../../../etc/passwd )
        @yardoc.assets.should be_empty
        @yardoc.run *%w( --asset a/b/c/d/../../../../../../etc/passwd )
        @yardoc.assets.should be_empty
        @yardoc.run *%w( --asset /etc/passwd )
        @yardoc.assets.should be_empty
        @yardoc.run *%w( --asset normal:/etc/passwd )
        @yardoc.assets.should be_empty
      end

      it "should allow from:to syntax" do
        FileUtils.should_receive(:cp_r).with('foo', 'doc/bar')
        @yardoc.run *%w( --asset foo:bar )
        @yardoc.assets.should == {'foo' => 'bar'}
      end
    end
  end
  
  describe '--no-private option' do
    it "should accept --no-private" do
      obj = mock(:object)
      obj.should_receive(:tag).ordered.with(:private).and_return(true)
      @yardoc.parse_arguments *%w( --no-private )
      @yardoc.options[:verifier].call(obj).should == false
    end

    it "should hide object if namespace is @private with --no-private" do
      ns = mock(:namespace)
      ns.stub!(:type).and_return(:module)
      ns.should_receive(:tag).ordered.with(:private).and_return(true)
      obj = mock(:object)
      obj.stub!(:namespace).and_return(ns)
      obj.should_receive(:tag).ordered.with(:private).and_return(false)
      @yardoc.parse_arguments *%w( --no-private )
      @yardoc.options[:verifier].call(obj).should == false
    end

    it "should not call #tag on namespace if namespace is proxy with --no-private" do
      ns = mock(:namespace)
      ns.should_receive(:is_a?).with(CodeObjects::Proxy).and_return(true)
      ns.should_not_receive(:tag)
      obj = mock(:object)
      obj.stub!(:type).and_return(:class)
      obj.stub!(:namespace).and_return(ns)
      obj.stub!(:visibility).and_return(:public)
      obj.should_receive(:tag).ordered.with(:private).and_return(false)
      @yardoc.parse_arguments *%w( --no-private )
      @yardoc.options[:verifier].call(obj).should == true
    end

    # @bug gh-197
    it "should not call #tag on namespace if namespace is proxy with --no-private" do
      Registry.clear
      YARD.parse_string "module Qux; class Foo::Bar; end; end"
      foobar = Registry.at('Foo::Bar')
      foobar.namespace.type = :module
      @yardoc.parse_arguments *%w( --no-private )
      @yardoc.options[:verifier].call(foobar).should == true
    end
    
    it "should not call #tag on proxy object" do # @bug gh-197
      @yardoc.parse_arguments *%w( --no-private )
      @yardoc.options[:verifier].call(P('ProxyClass')).should == true
    end

    it "should hide methods inside a 'private' class/module with --no-private" do
      Registry.clear
      YARD.parse_string <<-eof
        # @private
        class ABC
          def foo; end
        end
      eof
      @yardoc.parse_arguments *%w( --no-private )
      @yardoc.options[:verifier].call(Registry.at('ABC')).should be_false
      @yardoc.options[:verifier].call(Registry.at('ABC#foo')).should be_false
    end
  end
  
  describe '.yardopts and .document handling' do
    before do
      @yardoc.use_yardopts_file = true
    end
    
    it "should search for and use yardopts file specified by #options_file" do
      File.should_receive(:read_binary).with("test").and_return("-o \n\nMYPATH\nFILE1 FILE2")
      @yardoc.use_document_file = false
      @yardoc.options_file = "test"
      @yardoc.run
      @yardoc.options[:serializer].options[:basepath].should == "MYPATH"
      @yardoc.files.should == ["FILE1", "FILE2"]
    end

    it "should use String#shell_split to split .yardopts tokens" do
      optsdata = "foo bar"
      optsdata.should_receive(:shell_split)
      File.should_receive(:read_binary).with("test").and_return(optsdata)
      @yardoc.options_file = "test"
      @yardoc.run
    end

    it "should allow opts specified in command line to override yardopts file" do
      File.should_receive(:read_binary).with(".yardopts").and_return("-o NOTMYPATH")
      @yardoc.run("-o", "MYPATH", "FILE")
      @yardoc.options[:serializer].options[:basepath].should == "MYPATH"
      @yardoc.files.should == ["FILE"]
    end

    it "should load the RDoc .document file if found" do
      File.should_receive(:read_binary).with(".yardopts").and_return("-o NOTMYPATH")
      @yardoc.use_document_file = true
      @yardoc.stub!(:support_rdoc_document_file!).and_return(["FILE2", "FILE3"])
      @yardoc.run("-o", "MYPATH", "FILE1")
      @yardoc.options[:serializer].options[:basepath].should == "MYPATH"
      @yardoc.files.should == ["FILE2", "FILE3", "FILE1"]
    end
  end
  
  describe 'Query options' do
    before do
      Registry.clear
    end
    
    it "should setup visibility rules as verifier" do
      methobj = CodeObjects::MethodObject.new(:root, :test) {|o| o.visibility = :private }
      File.should_receive(:read_binary).with("test").and_return("--private")
      @yardoc.use_yardopts_file = true
      @yardoc.options_file = "test"
      @yardoc.run
      @yardoc.options[:verifier].call(methobj).should be_true
    end

    it "should accept a --query" do
      @yardoc.parse_arguments *%w( --query @return )
      @yardoc.options[:verifier].should be_a(Verifier)
    end

    it "should accept multiple --query arguments" do
      obj = mock(:object)
      obj.should_receive(:tag).ordered.with('return').and_return(true)
      obj.should_receive(:tag).ordered.with('tag').and_return(false)
      @yardoc.parse_arguments *%w( --query @return --query @tag )
      @yardoc.options[:verifier].should be_a(Verifier)
      @yardoc.options[:verifier].call(obj).should == false
    end
  end
  
  describe 'Extra file arguments' do
    it "should accept extra files if specified after '-' with source files" do
      Dir.should_receive(:glob).with('README*').and_return([])
      File.should_receive(:file?).with('extra_file1').and_return(true)
      File.should_receive(:file?).with('extra_file2').and_return(true)
      File.should_receive(:read).with('extra_file1').and_return('')
      File.should_receive(:read).with('extra_file2').and_return('')
      @yardoc.parse_arguments *%w( file1 file2 - extra_file1 extra_file2 )
      @yardoc.files.should == %w( file1 file2 )
      @yardoc.options[:files].should == 
        [CodeObjects::ExtraFileObject.new('extra_file1', ''), 
          CodeObjects::ExtraFileObject.new('extra_file2', '')]
    end

    it "should accept files section only containing extra files" do
      Dir.should_receive(:glob).with('README*').and_return([])
      @yardoc.parse_arguments *%w( - LICENSE )
      @yardoc.files.should == %w( {lib,app}/**/*.rb ext/**/*.c )
      @yardoc.options[:files].should == [CodeObjects::ExtraFileObject.new('LICENSE', '')]
    end

    it "should accept globs as extra files" do
      Dir.should_receive(:glob).with('README*').and_return []
      Dir.should_receive(:glob).with('*.txt').and_return ['a.txt', 'b.txt']
      File.should_receive(:read).with('a.txt').and_return('')
      File.should_receive(:read).with('b.txt').and_return('')
      File.should_receive(:file?).with('a.txt').and_return(true)
      File.should_receive(:file?).with('b.txt').and_return(true)
      @yardoc.parse_arguments *%w( file1 file2 - *.txt )
      @yardoc.files.should == %w( file1 file2 )
      @yardoc.options[:files].should == 
        [CodeObjects::ExtraFileObject.new('a.txt', ''), 
          CodeObjects::ExtraFileObject.new('b.txt', '')]
    end

    it "should warn if extra file is not found" do
      log.should_receive(:warn).with(/Could not find extra file: UNKNOWN/)
      @yardoc.parse_arguments *%w( - UNKNOWN )
    end

    it "should warn if readme file is not found" do
      log.should_receive(:warn).with(/Could not find readme file: UNKNOWN/)
      @yardoc.parse_arguments *%w( -r UNKNOWN )
    end
    
    it "should use first file as readme if no readme is specified when using --one-file" do
      Dir.should_receive(:glob).with('README*').and_return []
      Dir.should_receive(:glob).with('lib/*.rb').and_return(['lib/foo.rb'])
      File.should_receive(:read).with('lib/foo.rb').and_return('')
      @yardoc.parse_arguments *%w( --one-file lib/*.rb )
      @yardoc.options[:readme].should == CodeObjects::ExtraFileObject.new('lib/foo.rb', '')
    end
    
    it "should use readme it exists when using --one-file" do
      Dir.should_receive(:glob).with('README*').and_return ['README']
      File.should_receive(:read).with('README').and_return('')
      @yardoc.parse_arguments *%w( --one-file lib/*.rb )
      @yardoc.options[:readme].should == CodeObjects::ExtraFileObject.new('README', '')
    end
  end
  
  describe 'Source file arguments' do
    it "should accept no params and parse {lib,app}/**/*.rb ext/**/*.c" do
      @yardoc.parse_arguments
      @yardoc.files.should == %w( {lib,app}/**/*.rb ext/**/*.c )
    end
  end
  
  describe 'Tags options' do
    def tag_created(switch, factory_method)
      visible_tags = mock(:visible_tags)
      visible_tags.should_receive(:|).ordered.with([:foo])
      visible_tags.should_receive(:-).ordered.with([]).and_return(visible_tags)
      Tags::Library.should_receive(:define_tag).with('Foo', :foo, factory_method)
      Tags::Library.stub!(:visible_tags=)
      Tags::Library.should_receive(:visible_tags).at_least(1).times.and_return(visible_tags)
      @yardoc.parse_arguments("--#{switch}-tag", 'foo')
    end
    
    def tag_hidden(tag)
      visible_tags = mock(:visible_tags)
      visible_tags.should_receive(:|).ordered.with([tag])
      visible_tags.should_receive(:-).ordered.with([tag]).and_return([])
      Tags::Library.should_receive(:define_tag).with(tag.to_s.capitalize, tag, nil)
      Tags::Library.stub!(:visible_tags=)
      Tags::Library.should_receive(:visible_tags).at_least(1).times.and_return(visible_tags)
    end

    it "should accept --tag" do
      Tags::Library.should_receive(:define_tag).with('Title of Foo', :foo, nil)
      @yardoc.parse_arguments('--tag', 'foo:Title of Foo')
    end

    it "should accept --tag without title (and default to captialized tag name)" do
      Tags::Library.should_receive(:define_tag).with('Foo', :foo, nil)
      @yardoc.parse_arguments('--tag', 'foo')
    end
    
    it "should only list tag once if declared twice" do
      visible_tags = []
      Tags::Library.stub!(:define_tag)
      Tags::Library.stub!(:visible_tags).and_return([:foo])
      Tags::Library.stub!(:visible_tags=) {|value| visible_tags = value }
      @yardoc.parse_arguments('--tag', 'foo', '--tag', 'foo')
      visible_tags.should == [:foo]
    end

    it "should accept --type-tag" do
      tag_created 'type', :with_types
    end

    it "should accept --type-name-tag" do
      tag_created 'type-name', :with_types_and_name
    end

    it "should accept --name-tag" do
      tag_created 'name', :with_name
    end

    it "should accept --title-tag" do
      tag_created 'title', :with_title_and_text
    end
    
    it "should accept --hide-tag before tag is listed" do
      tag_hidden(:anewfoo)
      @yardoc.parse_arguments('--hide-tag', 'anewfoo', '--tag', 'anewfoo')
    end
    
    it "should accept --hide-tag after tag is listed" do
      tag_hidden(:anewfoo2)
      @yardoc.parse_arguments('--tag', 'anewfoo2', '--hide-tag', 'anewfoo2')
    end
    
    it "should accept --transitive-tag" do
      @yardoc.parse_arguments('--transitive-tag', 'foo')
      Tags::Library.transitive_tags.should include(:foo)
    end
  end
  
  describe 'Safe mode' do
    before do
      YARD::Config.stub!(:options).and_return(:safe_mode => true)
    end
    
    it "should not allow --load or -e in safe mode" do
      @yardoc.should_not_receive(:require)
      @yardoc.run('--load', 'foo')
      @yardoc.run('-e', 'foo')
    end

    it "should not allow --query in safe mode" do
      @yardoc.run('--query', 'foo')
      @yardoc.options[:verifier].expressions.should_not include("foo")
    end
    
    it "should not allow modifying the template paths" do
      YARD::Templates::Engine.should_not_receive(:register_template_path)
      @yardoc.run('-p', 'foo')
      @yardoc.run('--template-path', 'foo')
    end
  end
  
  describe 'Markup Loading' do
    it "should load rdoc markup if no markup is provided" do
      @yardoc.generate = true
      @yardoc.run
      @yardoc.options[:markup].should == :rdoc
    end
    
    it "should load rdoc markup even when no output is specified" do
      @yardoc.parse_arguments('--no-output')
      @yardoc.options[:markup].should == :rdoc
    end
    
    it "should warn if rdoc cannot be loaded and fallback to :none" do
      mod = YARD::Templates::Helpers::MarkupHelper
      mod.clear_markup_cache
      mod.const_get(:MARKUP_PROVIDERS).should_receive(:[]).with(:rdoc).and_return([{:lib => 'INVALID'}])
      log.should_receive(:warn).with(/Could not load default RDoc formatter/)
      @yardoc.generate = true
      @yardoc.run
      @yardoc.options[:markup].should == :none
      mod.clear_markup_cache
    end
  end
  
  describe '#run' do
    it "should parse_arguments if run() is called" do
      @yardoc.should_receive(:parse_arguments)
      @yardoc.run
    end

    it "should parse_arguments if run(arg1, arg2, ...) is called" do
      @yardoc.should_receive(:parse_arguments)
      @yardoc.run('--private', '-p', 'foo')
    end

    it "should not parse_arguments if run(nil) is called" do
      @yardoc.should_not_receive(:parse_arguments)
      @yardoc.run(nil)
    end
  end
end

require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + "/shared_signature_examples"
require 'ostruct'

describe YARD::Templates::Helpers::HtmlHelper do
  include YARD::Templates::Helpers::BaseHelper
  include YARD::Templates::Helpers::HtmlHelper
  include YARD::Templates::Helpers::MethodHelper
  
  def options; {} end

  describe '#h' do
    it "should use #h to escape HTML" do
      h('Usage: foo "bar" <baz>').should == "Usage: foo &quot;bar&quot; &lt;baz&gt;"
    end
  end
  
  describe '#charset' do
    it "should return foo if LANG=foo" do
      ENV.should_receive(:[]).with('LANG').and_return('shift_jis') if RUBY18
      Encoding.default_external.should_receive(:name).and_return('shift_jis') if defined?(Encoding)
      charset.should == 'shift_jis'
    end
    
    ['US-ASCII', 'ASCII-7BIT', 'ASCII-8BIT'].each do |type|
      it "should convert #{type} to iso-8859-1" do
        ENV.should_receive(:[]).with('LANG').and_return(type) if RUBY18
        Encoding.default_external.should_receive(:name).and_return(type) if defined?(Encoding)
        charset.should == 'iso-8859-1'
      end
    end
    
    it "should support utf8 as an encoding value for utf-8" do
      type = 'utf8'
      ENV.should_receive(:[]).with('LANG').and_return(type) if RUBY18
      Encoding.default_external.should_receive(:name).and_return(type) if defined?(Encoding)
      charset.should == 'utf-8'
    end
    
    it "should take file encoding if there is a file" do
      @file = OpenStruct.new(:contents => 'foo'.force_encoding('sjis'))
      charset.should == 'Shift_JIS' # not the correct charset name, but good enough
    end if RUBY19

    it "should take file encoding if there is a file" do
      ENV.stub!(:[]).with('LANG').and_return('utf-8') if RUBY18
      @file = OpenStruct.new(:contents => 'foo')
      charset.should == 'utf-8'
    end if RUBY18
    
    if RUBY18
      it "should return utf-8 if no LANG env is set" do
        ENV.should_receive(:[]).with('LANG').and_return(nil)
        charset.should == 'utf-8'
      end

      it "should only return charset part of lang" do
        ENV.should_receive(:[]).with('LANG').and_return('en_US.UTF-8')
        charset.should == 'utf-8'
      end
    end
  end
  
  describe '#format_types' do
    it "should include brackets by default" do
      text = ["String"]
      should_receive(:linkify).at_least(1).times.with("String", "String").and_return("String")
      format_types(text).should == format_types(text, true)
      format_types(text).should == "(<tt>String</tt>)"
    end

    it "should avoid brackets if brackets=false" do
      should_receive(:linkify).with("String", "String").and_return("String")
      should_receive(:linkify).with("Symbol", "Symbol").and_return("Symbol")
      format_types(["String", "Symbol"], false).should == "<tt>String</tt>, <tt>Symbol</tt>"
    end
    
    { "String" => [["String"], 
        "<tt><a href=''>String</a></tt>"], 
      "A::B::C" => [["A::B::C"], 
        "<tt><a href=''>A::B::C</a></tt>"],
      "Array<String>" => [["Array", "String"], 
        "<tt><a href=''>Array</a>&lt;<a href=''>String</a>&gt;</tt>"], 
      "Array<String, Symbol>" => [["Array", "String", "Symbol"], 
        "<tt><a href=''>Array</a>&lt;<a href=''>String</a>, <a href=''>Symbol</a>&gt;</tt>"],
      "Array<{String => Array<Symbol>}>" => [["Array", "String", "Array", "Symbol"], 
        "<tt><a href=''>Array</a>&lt;{<a href=''>String</a> =&gt; " +
        "<a href=''>Array</a>&lt;<a href=''>Symbol</a>&gt;}&gt;</tt>"]
    }.each do |text, values|
      it "should link all classes in #{text}" do
        should_receive(:h).with('<').at_least(text.count('<')).times.and_return("&lt;")
        should_receive(:h).with('>').at_least(text.count('>')).times.and_return("&gt;")
        values[0].each {|v| should_receive(:linkify).with(v, v).and_return("<a href=''>#{v}</a>") }
        format_types([text], false).should == values[1]
      end
    end
  end
  
  describe '#htmlify' do
    it "should not use hard breaks for textile markup (RedCloth specific)" do
      begin; require 'redcloth'; rescue LoadError; pending 'test requires redcloth gem' end
      htmlify("A\nB", :textile).should_not include("<br")
    end
    
    it "should handle various encodings" do
      stub!(:object).and_return(Registry.root)
      Encoding.default_internal = 'utf-8' if defined?(Encoding)
      htmlify("\xB0\xB1", :text)
      # TODO: add more encoding tests
    end
    
    it "should return regular text with :none markup" do
      htmlify("fo\no\n\nbar<>", :none).should == "fo\no<br/>bar&lt;&gt;"
    end
    
    it "should highlight ruby if markup is :ruby" do
      htmlify("class Foo; end", :ruby).should =~ /\A<pre class="code"><span/
    end
    
    it "should include file and htmlify it" do
      load_markup_provider(:rdoc)
      File.should_receive(:file?).with('foo.rdoc').and_return(true)
      File.should_receive(:read).with('foo.rdoc').and_return('= HI')
      htmlify("{include:file:foo.rdoc}", :rdoc).gsub(/\s+/, '').should == "<p><h1>HI</h1></p>"
    end
    
    it "should autolink URLs (markdown specific)" do
      log.enter_level(Logger::FATAL) do
        pending 'This test depends on markdown' unless markup_class(:markdown)
      end
      htmlify('http://example.com', :markdown).chomp.should ==
        '<p><a href="http://example.com">http://example.com</a></p>'
    end
    
    it "should not autolink URLs inside of {} (markdown specific)" do
      log.enter_level(Logger::FATAL) do
        pending 'This test depends on markdown' unless markup_class(:markdown)
      end
      htmlify('{http://example.com Title}', :markdown).chomp.should =~
        %r{<p><a href="http://example.com".*>Title</a></p>}
      htmlify('{http://example.com}', :markdown).chomp.should =~
        %r{<p><a href="http://example.com".*>http://example.com</a></p>}
    end
  end
  
  describe "#link_object" do
    before do
      stub!(:object).and_return(CodeObjects::NamespaceObject.new(nil, :YARD))
    end
    
    it "should return the object path if there's no serializer and no title" do
      stub!(:serializer).and_return nil
      link_object(CodeObjects::NamespaceObject.new(nil, :YARD)).should == "YARD"
    end
  
    it "should return the title if there's a title but no serializer" do
      stub!(:serializer).and_return nil
      link_object(CodeObjects::NamespaceObject.new(nil, :YARD), 'title').should == "title"
    end

    it "should link objects from overload tag" do
      YARD.parse_string <<-'eof'
        module Foo
          class Bar; def a; end end
          class Baz
            # @overload a
            def a; end
          end
        end
      eof
      obj = Registry.at('Foo::Baz#a').tag(:overload)
      foobar = Registry.at('Foo::Bar')
      foobaz = Registry.at('Foo::Baz')
      serializer = Serializers::FileSystemSerializer.new
      stub!(:serializer).and_return(serializer)
      stub!(:object).and_return(obj)
      link_object("Bar#a").should =~ %r{href="Bar.html#a-instance_method"}
    end
    
    it "should use relative path in title" do
      CodeObjects::ModuleObject.new(:root, :YARD)
      CodeObjects::ClassObject.new(P('YARD'), :Bar)
      stub!(:object).and_return(CodeObjects::ModuleObject.new(P('YARD'), :Foo))
      serializer = Serializers::FileSystemSerializer.new
      stub!(:serializer).and_return(serializer)
      link_object("Bar").should =~ %r{>Bar</a>}
    end
    
    it "should use relative path to parent class in title" do
      root = CodeObjects::ModuleObject.new(:root, :YARD)
      obj = CodeObjects::ModuleObject.new(root, :SubModule)
      stub!(:object).and_return(obj)
      serializer = Serializers::FileSystemSerializer.new
      stub!(:serializer).and_return(serializer)
      link_object("YARD").should =~ %r{>YARD</a>}
    end
  end

  describe '#url_for' do
    before { Registry.clear }
  
    it "should return nil if serializer is nil" do
      stub!(:serializer).and_return nil
      stub!(:object).and_return Registry.root
      url_for(P("Mod::Class#meth")).should be_nil
    end
  
    it "should return nil if serializer does not implement #serialized_path" do
      stub!(:serializer).and_return Serializers::Base.new
      stub!(:object).and_return Registry.root
      url_for(P("Mod::Class#meth")).should be_nil
    end
  
    it "should link to a path/file for a namespace object" do
      stub!(:serializer).and_return Serializers::FileSystemSerializer.new
      stub!(:object).and_return Registry.root
    
      yard = CodeObjects::ModuleObject.new(:root, :YARD)
      url_for(yard).should == 'YARD.html'
    end
  
    it "should link to the object's namespace path/file and use the object as the anchor" do
      stub!(:serializer).and_return Serializers::FileSystemSerializer.new
      stub!(:object).and_return Registry.root
    
      yard = CodeObjects::ModuleObject.new(:root, :YARD)
      meth = CodeObjects::MethodObject.new(yard, :meth)
      url_for(meth).should == 'YARD.html#meth-instance_method'
    end

    it "should properly urlencode methods with punctuation in links" do
      obj = CodeObjects::MethodObject.new(nil, :/)
      serializer = mock(:serializer)
      serializer.stub!(:serialized_path).and_return("file.html")
      stub!(:serializer).and_return(serializer)
      stub!(:object).and_return(obj)
      url_for(obj).should == "#%2F-instance_method"
    end
  end

  describe '#anchor_for' do
    it "should not urlencode data when called directly" do
      obj = CodeObjects::MethodObject.new(nil, :/)
      anchor_for(obj).should == "/-instance_method"
    end
  end

  describe '#resolve_links' do
    def parse_link(link)
      results = {}
      link =~ /<a (.+?)>(.+?)<\/a>/m
      params, results[:inner_text] = $1, $2
      params.scan(/\s*(\S+?)=['"](.+?)['"]\s*/).each do |key, value|
        results[key.to_sym] = value.gsub(/^["'](.+)["']$/, '\1')
      end
      results
    end
    
    it "should escape {} syntax with backslash (\\{foo bar})" do
      input  = '\{foo bar} \{XYZ} \{file:FOO}'
      output = '{foo bar} {XYZ} {file:FOO}'
      resolve_links(input).should == output
    end

    it "should link static files with file: prefix" do
      stub!(:serializer).and_return Serializers::FileSystemSerializer.new
      stub!(:object).and_return Registry.root

      parse_link(resolve_links("{file:TEST.txt#abc}")).should == {
        :inner_text => "TEST",
        :title => "TEST",
        :href => "file.TEST.html#abc"
      }
      parse_link(resolve_links("{file:TEST.txt title}")).should == {
        :inner_text => "title",
        :title => "title",
        :href => "file.TEST.html"
      }
    end
  
    it "should create regular links with http:// or https:// prefixes" do
      parse_link(resolve_links("{http://example.com}")).should == {
        :inner_text => "http://example.com",
        :target => "_parent",
        :href => "http://example.com",
        :title => "http://example.com"
      }
      parse_link(resolve_links("{http://example.com title}")).should == {
        :inner_text => "title",
        :target => "_parent",
        :href => "http://example.com",
        :title => "title"
      }
    end
    
    it "should create mailto links with mailto: prefixes" do
      parse_link(resolve_links('{mailto:joanna@example.com}')).should == {
        :inner_text => 'mailto:joanna@example.com',
        :target => '_parent',
        :href => 'mailto:joanna@example.com',
        :title => 'mailto:joanna@example.com'
      }
      parse_link(resolve_links('{mailto:steve@example.com Steve}')).should == {
        :inner_text => 'Steve',
        :target => '_parent',
        :href => 'mailto:steve@example.com',
        :title => 'Steve'
      }
    end
    
    it "should ignore {links} that begin with |...|" do
      resolve_links("{|x|x == 1}").should == "{|x|x == 1}"
    end
    
    it "should gracefully ignore {} in links" do
      should_receive(:linkify).with('Foo', 'Foo').and_return('FOO')
      resolve_links("{} {} {Foo Foo}").should == '{} {} FOO'
    end
    
    %w(tt code pre).each do |tag|
      it "should ignore links in <#{tag}>" do
        text = "<#{tag}>{Foo}</#{tag}>"
        resolve_links(text).should == text
      end
    end

    it "should resolve {Name}" do
      should_receive(:link_file).with('TEST', nil, nil).and_return('')
      resolve_links("{file:TEST}")
    end

    it "should resolve ({Name})" do
      should_receive(:link_file).with('TEST', nil, nil).and_return('')
      resolve_links("({file:TEST})")
    end
    
    it "should resolve link with newline in title-part" do
      parse_link(resolve_links("{http://example.com foo\nbar}")).should == {
        :inner_text => "foo bar",
        :target => "_parent",
        :href => "http://example.com",
        :title => "foo bar"
      }
    end
    
    it "should warn about missing reference at right file location for object" do
      YARD.parse_string <<-eof
        # Comments here
        # And a reference to {InvalidObject}
        class MyObject; end
      eof
      logger = mock(:log)
      logger.should_receive(:warn).ordered.with("In file `(stdin)':2: Cannot resolve link to InvalidObject from text:")
      logger.should_receive(:warn).ordered.with("...{InvalidObject}")
      stub!(:log).and_return(logger)
      stub!(:object).and_return(Registry.at('MyObject'))
      resolve_links(object.docstring)
    end
    
    it "should show ellipsis on either side if there is more on the line in a reference warning" do
      YARD.parse_string <<-eof
        # {InvalidObject1} beginning of line
        # end of line {InvalidObject2}
        # Middle of {InvalidObject3} line
        # {InvalidObject4}
        class MyObject; end
      eof
      logger = mock(:log)
      logger.should_receive(:warn).ordered.with("In file `(stdin)':1: Cannot resolve link to InvalidObject1 from text:")
      logger.should_receive(:warn).ordered.with("{InvalidObject1}...")
      logger.should_receive(:warn).ordered.with("In file `(stdin)':2: Cannot resolve link to InvalidObject2 from text:")
      logger.should_receive(:warn).ordered.with("...{InvalidObject2}")
      logger.should_receive(:warn).ordered.with("In file `(stdin)':3: Cannot resolve link to InvalidObject3 from text:")
      logger.should_receive(:warn).ordered.with("...{InvalidObject3}...")
      logger.should_receive(:warn).ordered.with("In file `(stdin)':4: Cannot resolve link to InvalidObject4 from text:")
      logger.should_receive(:warn).ordered.with("{InvalidObject4}")
      stub!(:log).and_return(logger)
      stub!(:object).and_return(Registry.at('MyObject'))
      resolve_links(object.docstring)
    end
    
    it "should warn about missing reference for file template (no object)" do
      @file = CodeObjects::ExtraFileObject.new('myfile.txt', '')
      logger = mock(:log)
      logger.should_receive(:warn).ordered.with("In file `myfile.txt':3: Cannot resolve link to InvalidObject from text:")
      logger.should_receive(:warn).ordered.with("...{InvalidObject Some Title}")
      stub!(:log).and_return(logger)
      stub!(:object).and_return(Registry.root)
      resolve_links(<<-eof)
        Hello world
        This is a line
        And {InvalidObject Some Title}
        And more.
      eof
    end
  end

  describe '#signature' do
    before do
      @results = {
        :regular => "- (Object) <strong>foo</strong>",
        :default_return => "- (Hello) <strong>foo</strong>",
        :no_default_return => "- <strong>foo</strong>",
        :private_class => "+ (Object) <strong>foo</strong>  <span class=\"extras\">(private)</span>",
        :single => "- (String) <strong>foo</strong>",
        :two_types => "- (String, Symbol) <strong>foo</strong>",
        :two_types_multitag => "- (String, Symbol) <strong>foo</strong>",
        :type_nil => "- (Type<sup>?</sup>) <strong>foo</strong>",
        :type_array => "- (Type<sup>+</sup>) <strong>foo</strong>",
        :multitype => "- (Type, ...) <strong>foo</strong>",
        :void => "- (void) <strong>foo</strong>",
        :hide_void => "- <strong>foo</strong>",
        :block => "- (Object) <strong>foo</strong> {|a, b, c| ... }",
        :empty_overload => '- (String) <strong>foobar</strong>'
      }
    end
    
    def format_types(types, brackets = false) types.join(", ") end
    def signature(obj, link = false) super(obj, link).strip end
    
    it_should_behave_like "signature"
    
    it "should link to regular method if overload name does not have the same method name" do
      YARD.parse_string <<-eof
        class Foo
          # @overload bar(a, b, c)
          def foo; end
        end
      eof
      serializer = mock(:serializer)
      serializer.stub!(:serialized_path).with(Registry.at('Foo')).and_return('')
      stub!(:serializer).and_return(serializer)
      stub!(:object).and_return(Registry.at('Foo'))
      signature(Registry.at('Foo#foo').tag(:overload), true).should == 
        "<a href=\"#foo-instance_method\" title=\"#bar (instance method)\">- <strong>bar</strong>(a, b, c) </a>"
    end
  end

  describe '#html_syntax_highlight' do
    before do
      stub!(:options).and_return(:no_highlight => false)
      stub!(:object).and_return(Registry.root)
    end
    
    def fix_rspec2_mock_teardown
      return unless defined?(RSpec)
      should_receive(:respond_to?).with(:teardown_mocks_for_rspec).and_return(false)
      should_receive(:respond_to?).with(:verify_mocks_for_rspec).and_return(false)
    end
    
    it "should return empty string on nil input" do
      html_syntax_highlight(nil).should == ''
    end
    
    it "should call #html_syntax_highlight_ruby by default" do
      Registry.root.source_type = nil
      should_receive(:html_syntax_highlight_ruby).with('def x; end')
      html_syntax_highlight('def x; end')
    end
    
    it "should call #html_syntax_highlight_NAME if there's an object with a #source_type" do
      Registry.root.source_type = :NAME
      fix_rspec2_mock_teardown
      should_receive(:respond_to?).with('html_syntax_highlight_NAME').and_return(true)
      should_receive(:html_syntax_highlight_NAME).and_return("foobar")
      html_syntax_highlight('def x; end').should == 'foobar'
    end

    it "should call html_syntax_highlight_NAME if source starts with !!!NAME" do
      fix_rspec2_mock_teardown
      should_receive(:respond_to?).with('html_syntax_highlight_NAME').and_return(true)
      should_receive(:html_syntax_highlight_NAME).and_return("foobar")
      html_syntax_highlight(<<-eof
        !!!NAME
        def x; end
      eof
      ).should == "foobar"
    end
    
    it "should not highlight if :no_highlight option is true" do
      stub!(:options).and_return(:no_highlight => true)
      should_not_receive(:html_syntax_highlight_ruby)
      html_syntax_highlight('def x; end').should == 'def x; end'
    end
    
    it "should not highlight if there is no highlight method specified by !!!NAME" do
      fix_rspec2_mock_teardown
      should_receive(:respond_to?).with('html_syntax_highlight_NAME').and_return(false)
      should_not_receive(:html_syntax_highlight_NAME)
      html_syntax_highlight("!!!NAME\ndef x; end").should == "def x; end"
    end
    
    it "should highlight as ruby if htmlify(text, :ruby) is called" do
      should_receive(:html_syntax_highlight_ruby).with('def x; end').and_return('x')
      htmlify('def x; end', :ruby).should == '<pre class="code">x</pre>'
    end
  end
  
  describe '#link_url' do
    it "should add target if scheme is provided" do
      link_url("http://url.com").should include(" target=\"_parent\"")
      link_url("https://url.com").should include(" target=\"_parent\"")
      link_url("irc://url.com").should include(" target=\"_parent\"")
      link_url("../not/scheme").should_not include("target")
    end
  end
end

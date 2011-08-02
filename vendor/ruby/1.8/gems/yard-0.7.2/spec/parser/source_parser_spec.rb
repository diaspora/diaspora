require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class MyParser < Parser::Base; end

shared_examples_for "parser type registration" do
  after do
    Parser::SourceParser.parser_types.delete(:my_parser)
    Parser::SourceParser.parser_type_extensions.delete(:my_parser)
  end
end

describe YARD::Parser::SourceParser do
  before do 
    Registry.clear
  end
  
  def parse_list(*list)
    files = list.map do |v|
      filename, source = *v
      File.stub!(:read_binary).with(filename).and_return(source)
      filename
    end
    Parser::SourceParser.send(:parse_in_order, *files)
  end

  def before_list(&block)
    Parser::SourceParser.before_parse_list(&block)
  end

  def after_list(&block)
    Parser::SourceParser.after_parse_list(&block)
  end

  def before_file(&block)
    Parser::SourceParser.before_parse_file(&block)
  end

  def after_file(&block)
    Parser::SourceParser.after_parse_file(&block)
  end
  
  describe '.before_parse_list' do
    before do
      Parser::SourceParser.before_parse_list_callbacks.clear
      Parser::SourceParser.after_parse_list_callbacks.clear
    end

    it "should handle basic callback support" do
      before_list do |files, globals|
        files.should == ['foo.rb', 'bar.rb']
        globals.should == OpenStruct.new
      end
      parse_list ['foo.rb', 'foo!'], ['bar.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil
    end
    
    it "should support multiple callbacks" do
      checks = []
      before_list { checks << :one }
      before_list { checks << :two }
      parse_list ['file.rb', ''], ['file2.rb', ''], ['file3.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil  
      checks.should == [:one, :two]
    end
    
    it "should cancel parsing if it returns false" do
      checks = []
      before_list { checks << :one }
      before_list { false }
      before_list { checks << :three }
      parse_list ['file.rb', ''], ['file2.rb', ''], ['file3.rb', 'class Foo; end']
      Registry.at('Foo').should be_nil
      checks.should == [:one]
    end
    
    it "should not cancel on nil" do
      checks = []
      before_list { checks << :one }
      before_list { nil }
      before_list { checks << :two }
      parse_list ['file.rb', ''], ['file2.rb', ''], ['file3.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil
      checks.should == [:one, :two]
    end
    
    it "should pass in globals" do
      before_list {|f,g| g.x = 1 }
      before_list {|f,g| g.x += 1 }
      before_list {|f,g| g.x += 1 }
      after_list {|f,g| g.x.should == 3 }
      parse_list ['file.rb', ''], ['file2.rb', ''], ['file3.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil
    end
  end

  describe '.after_parse_list' do
    before do
      Parser::SourceParser.before_parse_list_callbacks.clear
      Parser::SourceParser.after_parse_list_callbacks.clear
    end

    it "should handle basic callback support and maintain files/globals" do
      before_list do |f,g| g.foo = :bar end
      after_list do |files, globals|
        files.should == ['foo.rb', 'bar.rb']
        globals.foo.should == :bar
      end
      parse_list ['foo.rb', 'foo!'], ['bar.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil
    end
    
    it "should support multiple callbacks" do
      checks = []
      after_list { checks << :one }
      after_list { checks << :two }
      parse_list ['file.rb', ''], ['file2.rb', ''], ['file3.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil  
      checks.should == [:one, :two]
    end
    
    it "should not cancel parsing if it returns false" do
      checks = []
      after_list { checks << :one }
      after_list { false }
      after_list { checks << :three }
      parse_list ['file.rb', ''], ['file2.rb', ''], ['file3.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil
      checks.should == [:one, :three]
    end
  end

  describe '.before_parse_file' do
    before do
      Parser::SourceParser.before_parse_file_callbacks.clear
      Parser::SourceParser.after_parse_file_callbacks.clear
    end

    it "should handle basic callback support" do
      before_file do |parser|
        parser.contents.should == 'class Foo; end'
        parser.file.should =~ /(foo|bar)\.rb/
      end
      parse_list ['foo.rb', 'class Foo; end'], ['bar.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil
    end
    
    it "should support multiple callbacks" do
      checks = []
      before_file { checks << :one }
      before_file { checks << :two }
      parse_list ['file.rb', ''], ['file2.rb', ''], ['file3.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil  
      checks.should == [:one, :two, :one, :two, :one, :two]
    end
    
    it "should cancel parsing if it returns false" do
      checks = []
      before_file { checks << :one }
      before_file { false }
      before_file { checks << :three }
      parse_list ['file.rb', ''], ['file2.rb', ''], ['file3.rb', 'class Foo; end']
      Registry.at('Foo').should be_nil
      checks.should == [:one, :one, :one]
    end
    
    it "should not cancel on nil" do
      checks = []
      before_file { checks << :one }
      before_file { nil }
      before_file { checks << :two }
      parse_list ['file.rb', ''], ['file2.rb', ''], ['file3.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil
      checks.should == [:one, :two, :one, :two, :one, :two]
    end
  end
  
  describe '.after_parse_file' do
    before do
      Parser::SourceParser.before_parse_file_callbacks.clear
      Parser::SourceParser.after_parse_file_callbacks.clear
    end

    it "should handle basic callback support" do
      after_file do |parser|
        parser.contents.should == 'class Foo; end'
        parser.file.should =~ /(foo|bar)\.rb/
      end
      parse_list ['foo.rb', 'class Foo; end'], ['bar.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil
    end
    
    it "should support multiple callbacks" do
      checks = []
      after_file { checks << :one }
      after_file { checks << :two }
      parse_list ['file.rb', ''], ['file2.rb', ''], ['file3.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil  
      checks.should == [:one, :two, :one, :two, :one, :two]
    end
    
    it "should not cancel parsing if it returns false" do
      checks = []
      after_file { checks << :one }
      after_file { false }
      after_file { checks << :three }
      parse_list ['file.rb', ''], ['file2.rb', ''], ['file3.rb', 'class Foo; end']
      Registry.at('Foo').should_not be_nil
      checks.should == [:one, :three, :one, :three, :one, :three]
    end
  end
  
  describe '.register_parser_type' do
    it_should_behave_like "parser type registration"
    
    it "should register a subclass of Parser::Base" do
      parser = mock(:parser)
      parser.should_receive(:parse)
      MyParser.should_receive(:new).with('content', '(stdin)').and_return(parser)
      Parser::SourceParser.register_parser_type(:my_parser, MyParser, 'myparser')
      Parser::SourceParser.parse_string('content', :my_parser)
    end
    
    it "should require class to be a subclass of Parser::Base" do
      lambda { Parser::SourceParser.register_parser_type(:my_parser, String) }.should raise_error(ArgumentError)
      lambda { Parser::SourceParser.register_parser_type(:my_parser, Parser::Base) }.should raise_error(ArgumentError)
    end
  end
  
  describe '.parser_type_for_extension' do 
    it_should_behave_like "parser type registration"

    it "should find an extension in a registered array of extensions" do
      Parser::SourceParser.register_parser_type(:my_parser, MyParser, ['a', 'b', 'd'])
      Parser::SourceParser.parser_type_for_extension('a').should == :my_parser
      Parser::SourceParser.parser_type_for_extension('b').should == :my_parser
      Parser::SourceParser.parser_type_for_extension('d').should == :my_parser
      Parser::SourceParser.parser_type_for_extension('c').should_not == :my_parser
    end
    
    it "should find an extension in a Regexp" do
      Parser::SourceParser.register_parser_type(:my_parser, MyParser, /abc$/)
      Parser::SourceParser.parser_type_for_extension('dabc').should == :my_parser
      Parser::SourceParser.parser_type_for_extension('dabcd').should_not == :my_parser
    end
    
    it "should find an extension in a list of Regexps" do
      Parser::SourceParser.register_parser_type(:my_parser, MyParser, [/ab$/, /abc$/])
      Parser::SourceParser.parser_type_for_extension('dabc').should == :my_parser
      Parser::SourceParser.parser_type_for_extension('dabcd').should_not == :my_parser
    end
    
    it "should find an extension in a String" do
      Parser::SourceParser.register_parser_type(:my_parser, MyParser, "abc")
      Parser::SourceParser.parser_type_for_extension('abc').should == :my_parser
      Parser::SourceParser.parser_type_for_extension('abcd').should_not == :my_parser
    end
  end
  
  describe '#parse_string' do
    it "should parse basic Ruby code" do
      YARD.parse_string(<<-eof)
        module Hello
          class Hi
            # Docstring
            # Docstring2
            def me; "VALUE" end
          end
        end
      eof
      Registry.at(:Hello).should_not == nil
      Registry.at("Hello::Hi#me").should_not == nil
      Registry.at("Hello::Hi#me").docstring.should == "Docstring\nDocstring2"
      Registry.at("Hello::Hi#me").docstring.line_range.should == (3..4)
    end
    
    it "should parse Ruby code with metaclasses" do
      YARD.parse_string(<<-eof)
        module Hello
          class Hi
            class <<self
              # Docstring
              def me; "VALUE" end
            end
          end
        end
      eof
      Registry.at(:Hello).should_not == nil
      Registry.at("Hello::Hi.me").should_not == nil
      Registry.at("Hello::Hi.me").docstring.should == "Docstring"
    end
    
    it "should only use prepended comments for an object" do
      YARD.parse_string(<<-eof)
        # Test
        
        # PASS
        module Hello
        end # FAIL
      eof
      Registry.at(:Hello).docstring.should == "PASS"
    end
    
    it "should not add comments appended to last line of block" do
      YARD.parse_string <<-eof
        module Hello2
        end # FAIL
      eof
      Registry.at(:Hello2).docstring.should be_blank
    end
    
    it "should add comments appended to an object's first line" do
      YARD.parse_string <<-eof
        module Hello # PASS
          HELLO
        end

        module Hello2 # PASS
          # ANOTHER PASS
          def x; end
        end
      eof

      Registry.at(:Hello).docstring.should == "PASS"
      Registry.at(:Hello2).docstring.should == "PASS"
      Registry.at('Hello2#x').docstring.should == "ANOTHER PASS"
    end
    
    it "should take preceeding comments only if they exist" do
      YARD.parse_string <<-eof
        # PASS
        module Hello # FAIL
          HELLO
        end
      eof

      Registry.at(:Hello).docstring.should == "PASS"
    end
    
    it "should strip all hashes prefixed on comment line" do
      YARD.parse_string(<<-eof)
        ### PASS
        #### PASS
        ##### PASS
        module Hello
        end
      eof
      Registry.at(:Hello).docstring.should == "PASS\nPASS\nPASS"
    end
    
    it "should handle =begin/=end style comments" do
      YARD.parse_string "=begin\nfoo\nbar\n=end\nclass Foo; end\n"
      Registry.at(:Foo).docstring.should == "foo\nbar"

      YARD.parse_string "=begin\n\nfoo\nbar\n=end\nclass Foo; end\n"
      Registry.at(:Foo).docstring.should == "foo\nbar"

      YARD.parse_string "=begin\nfoo\n\nbar\n=end\nclass Foo; end\n"
      Registry.at(:Foo).docstring.should == "foo\n\nbar"
    end
    
    it "should know about docstrings starting with ##" do
      {'#' => false, '##' => true}.each do |hash, expected|
        YARD.parse_string "#{hash}\n# Foo bar\nclass Foo; end"
        Registry.at(:Foo).docstring.hash_flag.should == expected
      end
    end
    
    it "should remove shebang from initial file comments" do
      YARD.parse_string "#!/bin/ruby\n# this is a comment\nclass Foo; end"
      Registry.at(:Foo).docstring.should == "this is a comment"
    end
    
    it "should remove encoding line from initial file comments" do
      YARD.parse_string "# encoding: utf-8\n# this is a comment\nclass Foo; end"
      Registry.at(:Foo).docstring.should == "this is a comment"
    end
    
    it "should add macros on any object" do
      YARD.parse_string <<-eof
        # @macro [new] foo
        # This is a macro
        # @return [String] the string
        class Foo
          # @macro foo
          def foo; end
        end
      eof
      
      macro = CodeObjects::MacroObject.find('foo')
      macro.macro_data.should == "This is a macro\n@return [String] the string"
      Registry.at('Foo').docstring.all.should ==  macro.macro_data
      Registry.at('Foo#foo').docstring.all.should == macro.macro_data
    end
  end

  describe '#parse' do
    it "should parse a basic Ruby file" do
      parse_file :example1, __FILE__
      Registry.at(:Hello).should_not == nil
      Registry.at("Hello::Hi#me").should_not == nil
      Registry.at("Hello::Hi#me").docstring.should == "Docstring"
    end
  
    it "should parse a set of file globs" do
      Dir.should_receive(:[]).with('lib/**/*.rb').and_return([])
      YARD.parse('lib/**/*.rb')
    end
  
    it "should parse a set of absolute paths" do
      Dir.should_not_receive(:[]).and_return([])
      File.should_receive(:file?).with('/path/to/file').and_return(true)
      File.should_receive(:read_binary).with('/path/to/file').and_return("")
      YARD.parse('/path/to/file')
    end
    
    it "should clean paths before parsing" do
      File.should_receive(:open).and_return("")
      parser = Parser::SourceParser.new(:ruby, true)
      parser.parse('a//b//c')
      parser.file.should == 'a/b/c'
    end

    it "should parse files with '*' in them as globs and others as absolute paths" do
      Dir.should_receive(:[]).with('*.rb').and_return(['a.rb', 'b.rb'])
      File.should_receive(:file?).with('/path/to/file').and_return(true)
      File.should_receive(:file?).with('a.rb').and_return(true)
      File.should_receive(:file?).with('b.rb').and_return(true)
      File.should_receive(:read_binary).with('/path/to/file').and_return("")
      File.should_receive(:read_binary).with('a.rb').and_return("")
      File.should_receive(:read_binary).with('b.rb').and_return("")
      YARD.parse ['/path/to/file', '*.rb']
    end
    
    it "should convert directories into globs" do
      Dir.should_receive(:[]).with('foo/**/*.{rb,c}').and_return(['foo/a.rb', 'foo/bar/b.rb'])
      File.should_receive(:directory?).with('foo').and_return(true)
      File.should_receive(:file?).with('foo/a.rb').and_return(true)
      File.should_receive(:file?).with('foo/bar/b.rb').and_return(true)
      File.should_receive(:read_binary).with('foo/a.rb').and_return("")
      File.should_receive(:read_binary).with('foo/bar/b.rb').and_return("")
      YARD.parse ['foo']
    end
    
    it "should use Registry.checksums cache if file is cached" do
      data = 'DATA'
      hash = Registry.checksum_for(data)
      cmock = mock(:cmock)
      cmock.should_receive(:[]).with('foo/bar').and_return(hash)
      Registry.should_receive(:checksums).and_return(cmock)
      File.should_receive(:file?).with('foo/bar').and_return(true)
      File.should_receive(:read_binary).with('foo/bar').and_return(data)
      YARD.parse('foo/bar')
    end
    
    it "should support excluded paths" do
      File.should_receive(:file?).with('foo/bar').and_return(true)
      File.should_receive(:file?).with('foo/baz').and_return(true)
      File.should_not_receive(:read_binary)
      YARD.parse(["foo/bar", "foo/baz"], ["foo", /baz$/])
    end
    
    it "should convert file contents to proper encoding if coding line is present" do
      valid = []
      valid << "# encoding: sjis"
      valid << "# xxxxxencoding: sjis"
      valid << "# xxxxxencoding: sjis xxxxxx"
      valid << "# ENCODING: sjis"
      valid << "#coDiNG: sjis"
      valid << "# -*- coding: sjis -*-"
      valid << "### coding: sjis"
      valid << "# encoding=sjis"
      valid << "# encoding:sjis"
      valid << "# encoding   =   sjis"
      valid << "# encoding   ==   sjis"
      valid << "# encoding :  sjis"
      valid << "# encoding ::  sjis"
      valid << "#!/bin/shebang\n# encoding: sjis"
      valid << "#!/bin/shebang\r\n# coding: sjis"
      invalid = []
      invalid << "#\n# encoding: sjis"
      invalid << "#!/bin/shebang\n#\n# encoding: sjis"
      invalid << "# !/bin/shebang\n# encoding: sjis"
      {:should => valid, :should_not => invalid}.each do |msg, list|
        list.each do |src|
          Registry.clear
          parser = Parser::SourceParser.new
          File.should_receive(:read_binary).with('tmpfile').and_return(src)
          result = parser.parse("tmpfile")
          if HAVE_RIPPER && RUBY19
            result.enumerator[0].source.encoding.to_s.send(msg) == 'Shift_JIS'
          end
          result.encoding_line.send(msg) == src.split("\n").last
        end
      end
    end

    Parser::SourceParser::ENCODING_BYTE_ORDER_MARKS.each do |encoding, bom|
      it "should understand #{encoding.upcase} BOM" do
        parser = Parser::SourceParser.new
        src = bom + "class FooBar; end".force_encoding('binary')
        src.force_encoding('binary')
        File.should_receive(:read_binary).with('tmpfile').and_return(src)
        result = parser.parse('tmpfile')
        Registry.all(:class).first.path.should == "FooBar"
        result.enumerator[0].source.encoding.to_s.downcase.should == encoding
      end
    end if HAVE_RIPPER && RUBY19
  end
  
  describe '#parse_in_order' do
    def in_order_parse(*files)
      paths = files.map {|f| File.join(File.dirname(__FILE__), 'examples', f.to_s + '.rb.txt') }
      YARD::Parser::SourceParser.parse(paths, [], Logger::DEBUG)
    end
    
    it "should attempt to parse files in order" do
      msgs = []
      log.should_receive(:debug) {|m| msgs << m }.at_least(:once)
      in_order_parse 'parse_in_order_001', 'parse_in_order_002'
      msgs[1].should =~ /Processing .+parse_in_order_001.+/
      msgs[2].should =~ /Missing object MyModule/
      msgs[3].should =~ /Processing .+parse_in_order_002.+/
      msgs[4].should =~ /Re-processing .+parse_in_order_001.+/
    end if CONTINUATIONS_SUPPORTED
    
    it "should attempt to order files by length (process toplevel files first)" do
      %w(a a/b a/b/c).each do |file|
        File.should_receive(:file?).with(file).and_return(true)
        File.should_receive(:read_binary).with(file).ordered.and_return('')
      end
      YARD.parse %w(a/b/c a/b a)
    end
  end
  
  describe '#parse_statements' do
    it "should display a warning for invalid parser type" do
      log.should_receive(:warn).with(/unrecognized file/)
      YARD::Parser::SourceParser.parse_string("int main() { }", :d)
    end
    
    if HAVE_RIPPER
      it "should display a warning for a syntax error (with new parser)" do
        err_msg = "Syntax error in `(stdin)`:(1,3): syntax error, unexpected $undefined, expecting $end"
        log.should_receive(:warn).with(err_msg)
        YARD::Parser::SourceParser.parse_string("$$$", :ruby)
      end
    end
    
    it "should handle groups" do
      Registry.clear
      YARD.parse_string <<-eof
        class A
          # @group Group Name
          def foo; end
          def foo2; end
        
          # @endgroup
        
          def bar; end
          
          # @group Group 2
          def baz; end
        end
      eof
      
      Registry.at('A').groups.should == ['Group Name', 'Group 2']
      Registry.at('A#bar').group.should be_nil
      Registry.at('A#foo').group.should == "Group Name"
      Registry.at('A#foo2').group.should == "Group Name"
      Registry.at('A#baz').group.should == "Group 2"
    end
  end
end
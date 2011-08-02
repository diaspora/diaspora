require File.dirname(__FILE__) + '/spec_helper'

describe YARD::Templates::Template do
  def template(path)
    YARD::Templates::Engine.template!(path, '/full/path/' + path.to_s)
  end

  before :each do
    YARD::Templates::ErbCache.clear!
  end
  
  describe '.include_parent' do
    it "should not include parent directory if parent directory is a template root path" do
      mod = template('q')
      mod.should_not include(template(''))
    end
    
    it "should include overridden parent directory" do
      Engine.stub!(:template_paths).and_return(['/foo', '/bar'])
      File.should_receive(:directory?).with('/foo/a/b').and_return(true)
      File.should_receive(:directory?).with('/bar/a/b').and_return(false)
      File.should_receive(:directory?).with('/foo/a').at_least(1).times.and_return(true)
      File.should_receive(:directory?).with('/bar/a').at_least(1).times.and_return(true)
      ancestors = Engine.template('a/b').ancestors.map {|c| c.class_name }
      ancestors[0, 3].should == %w( Template__foo_a_b Template__bar_a Template__foo_a )
    end
    
    it "should include parent directory template if exists" do
      mod1 = template('x')
      mod2 = template('x/y')
      mod2.should include(mod1)
    end
  end
  
  describe '.full_paths' do
    it "should list full_path" do
      mod = template(:a)
      mod.full_paths.should == ['/full/path/a']
    end
    
    it "should list paths of included modules" do
      mod = template(:a)
      mod.send(:include, template(:b))
      mod.full_paths.should == ['/full/path/a', '/full/path/b']
    end
    
    it "should list paths from modules of included modules" do
      mod = template(:c)
      mod.send(:include, template(:d))
      mod.send(:include, template(:a))
      mod.full_paths.should == ['c', 'a', 'b', 'd'].map {|o| '/full/path/' + o }
    end
    
    it "should only list full paths of modules that respond to full_paths" do
      mod = template(:d)
      mod.send(:include, Enumerable)
      mod.full_paths.should == ['/full/path/d']
    end
  end
  
  describe '.load_setup_rb' do
    it "should load setup.rb file for module" do
      File.should_receive(:file?).with('/full/path/e/setup.rb').and_return(true)
      File.should_receive(:read).with('/full/path/e/setup.rb').and_return('def success; end')
      template(:e).new.should respond_to(:success)
    end
  end
  
  describe '.T' do
    it "should load template from absolute path" do
      mod = template(:a)
      Engine.should_receive(:template).with('other')
      mod.T('other')
    end
  end
  
  describe '.find_file' do
    it "should find file in module's full_path" do
      File.should_receive(:file?).with('/full/path/a/basename').and_return(false)
      File.should_receive(:file?).with('/full/path/b/basename').and_return(true)
      template(:a).find_file('basename').should == '/full/path/b/basename'
    end
    
    it "should return nil if no file is found" do
      File.should_receive(:file?).with('/full/path/a/basename').and_return(false)
      File.should_receive(:file?).with('/full/path/b/basename').and_return(false)
      template(:a).find_file('basename').should be_nil
    end
  end
  
  describe '.find_nth_file' do
    it "should find 2nd existing file in template paths" do
      File.should_receive(:file?).with('/full/path/a/basename').and_return(true)
      File.should_receive(:file?).with('/full/path/b/basename').and_return(true)
      template(:a).find_nth_file('basename', 2).should == '/full/path/b/basename'
    end
    
    it "should return nil if no file is found" do
      File.should_receive(:file?).with('/full/path/a/basename').and_return(true)
      File.should_receive(:file?).with('/full/path/b/basename').and_return(true)
      template(:a).find_nth_file('basename', 3).should be_nil
    end
  end
  
  describe '.extra_includes' do
    it "should be included when a module is initialized" do
      module MyModule; end
      Template.extra_includes << MyModule
      template(:e).new.should be_kind_of(MyModule)
    end
  end
  
  describe '.is_a?' do
    it "should be kind of Template" do
      template(:e).is_a?(Template).should == true
    end
  end
  
  describe '#T' do
    it "should delegate to class method" do
      template(:e).should_receive(:T).with('test')
      template(:e).new.T('test')
    end
  end
  
  describe '#init' do
    it "should be called during initialization" do
      module YARD::Templates::Engine::Template__full_path_e
        def init; sections 1, 2, 3 end 
      end
      template(:e).new.sections.should == Section.new(nil, 1, 2, 3)
    end
  end
  
  describe '#file' do
    it "should read the file if it exists" do
      File.should_receive(:file?).with('/full/path/e/abc').and_return(true)
      IO.should_receive(:read).with('/full/path/e/abc').and_return('hello world')
      template(:e).new.file('abc').should == 'hello world'
    end
    
    it "should raise ArgumentError if the file does not exist" do
      File.should_receive(:file?).with('/full/path/e/abc').and_return(false)
      lambda { template(:e).new.file('abc') }.should raise_error(ArgumentError)
    end
    
    it "should replace {{{__super__}}} with inherited template contents if allow_inherited=true" do
      File.should_receive(:file?).with('/full/path/a/abc').twice.and_return(true)
      File.should_receive(:file?).with('/full/path/b/abc').and_return(true)
      IO.should_receive(:read).with('/full/path/a/abc').and_return('foo {{{__super__}}}')
      IO.should_receive(:read).with('/full/path/b/abc').and_return('bar')
      template(:a).new.file('abc', true).should == "foo bar"
    end

    it "should not replace {{{__super__}}} with inherited template contents if allow_inherited=false" do
      File.should_receive(:file?).with('/full/path/a/abc').and_return(true)
      IO.should_receive(:read).with('/full/path/a/abc').and_return('foo {{{__super__}}}')
      template(:a).new.file('abc').should == "foo {{{__super__}}}"
    end
  end
  
  describe '#superb' do
    it "should return the inherited erb template contents" do
      File.should_receive(:file?).with('/full/path/a/test.erb').and_return(true)
      File.should_receive(:file?).with('/full/path/b/test.erb').and_return(true)
      IO.should_receive(:read).with('/full/path/b/test.erb').and_return('bar')
      template = template(:a).new
      template.section = :test
      template.superb.should == "bar"
    end
    
    it "should work inside an erb template" do
      File.should_receive(:file?).with('/full/path/a/test.erb').twice.and_return(true)
      File.should_receive(:file?).with('/full/path/b/test.erb').and_return(true)
      IO.should_receive(:read).with('/full/path/a/test.erb').and_return('foo<%= superb %>!')
      IO.should_receive(:read).with('/full/path/b/test.erb').and_return('bar')
      template = template(:a).new
      template.section = :test
      template.erb(:test).should == "foobar!"
    end
  end
  
  describe '#sections' do
    it "should allow sections to be set if arguments are provided" do
      mod = template(:e).new
      mod.sections 1, 2, [3]
      mod.sections.should == Section.new(nil, 1, 2, [3])
    end
  end
  
  describe '#run' do
    it "should render all sections" do
      mod = template(:e).new
      mod.should_receive(:render_section).with(Section.new(:a)).and_return('a')
      mod.should_receive(:render_section).with(Section.new(:b)).and_return('b')
      mod.should_receive(:render_section).with(Section.new(:c)).and_return('c')
      mod.sections :a, :b, :c
      mod.run.should == 'abc'
    end
    
    it "should render all sections with options" do
      mod = template(:e).new
      mod.should_receive(:render_section).with(Section.new(:a)).and_return('a')
      mod.should_receive(:add_options).with(:a => 1).and_yield
      mod.sections :a
      mod.run(:a => 1).should == 'a'
    end
    
    it "should run section list if provided" do
      mod = template(:e).new
      mod.should_receive(:render_section).with(Section.new(:q))
      mod.should_receive(:render_section).with(Section.new(:x))
      mod.run({}, [:q, :x])
    end
    
    it "should accept a nil section as empty string" do
      mod = template(:e).new
      mod.should_receive(:render_section).with(Section.new(:a))
      mod.sections :a
      mod.run.should == ""
    end
  end
  
  describe '#add_options' do
    it "should set instance variables in addition to options" do
      mod = template(:f).new
      mod.send(:add_options, {:a => 1, :b => 2})
      mod.options.should == {:a => 1, :b => 2}
      mod.instance_variable_get("@a").should == 1
      mod.instance_variable_get("@b").should == 2
    end
    
    it "should set instance variables and options only for the block" do
      mod = template(:f).new
      mod.send(:add_options, {:a => 100, :b => 200}) do
        mod.options.should == {:a => 100, :b => 200}
      end
      mod.options.should_not == {:a => 100, :b => 200}
    end
  end
  
  describe '#render_section' do
    it "should call method if method exists by section name as Symbol" do
      mod = template(:f).new
      mod.should_receive(:respond_to?).with(:a).and_return(true)
      mod.should_receive(:respond_to?).with('a').and_return(true)
      mod.should_receive(:send).with(:a).and_return('a')
      mod.should_receive(:send).with('a').and_return('a')
      mod.run({}, [:a, 'a']).should == 'aa'
    end
    
    it "should call erb if no method exists by section name" do
      mod = template(:f).new
      mod.should_receive(:respond_to?).with(:a).and_return(false)
      mod.should_receive(:respond_to?).with('a').and_return(false)
      mod.should_receive(:erb).with(:a).and_return('a')
      mod.should_receive(:erb).with('a').and_return('a')
      mod.run({}, [:a, 'a']).should == 'aa'
    end
    
    it "should run a template if section is one" do
      mod2 = template(:g)
      mod2.should_receive(:run)
      mod = template(:f).new
      mod.sections mod2
      mod.run
    end
    
    it "should run a template instance if section is one" do
      mod2 = template(:g).new
      mod2.should_receive(:run)
      mod = template(:f).new
      mod.sections mod2
      mod.run
    end
  end 
  
  describe '#yield' do
    it "should yield a subsection" do
      mod = template(:e).new
      mod.sections :a, [:b, :c]
      class << mod
        def a; "(" + yield + ")" end
        def b; "b" end
        def c; "c" end
      end

      mod.run.should == "(b)"
    end
    
    it "should yield a subsection within a yielded subsection" do
      mod = template(:e).new
      mod.sections :a, [:b, [:c]]
      class << mod
        def a; "(" + yield + ")" end
        def b; yield end
        def c; "c" end
      end

      mod.run.should == "(c)"
    end
    
    it "should support arbitrary nesting" do
      mod = template(:e).new
      mod.sections :a, [:b, [:c, [:d, [:e]]]]
      class << mod
        def a; "(" + yield + ")" end
        def b; yield end
        def c; yield end
        def d; yield end
        def e; "e" end
      end

      mod.run.should == "(e)"
    end
    
    it "should yield first two elements if yield is called twice" do
      mod = template(:e).new
      mod.sections :a, [:b, :c, :d]
      class << mod
        def a; "(" + yield + yield + ")" end
        def b; 'b' end
        def c; "c" end
      end

      mod.run.should == "(bc)"
    end
    
    it "should ignore any subsections inside subsection yields" do
      mod = template(:e).new
      mod.sections :a, [:b, [:c], :d]
      class << mod
        def a; "(" + yield + yield + ")" end
        def b; 'b' end
        def d; "d" end
      end

      mod.run.should == "(bd)"
    end
    
    it "should allow extra options passed via yield" do
      mod = template(:e).new
      mod.sections :a, [:b]
      class << mod
        def a; "(" + yield(:x => "a") + ")" end
        def b; options[:x] + @x end
      end

      mod.run.should == "(aa)"
    end
  end
  
  describe '#yieldall' do
    it "should yield all subsections" do
      mod = template(:e).new
      mod.sections :a, [:b, [:d, [:e]], :c]
      class << mod
        def a; "(" + yieldall + ")" end
        def b; "b" + yieldall end
        def c; "c" end
        def d; 'd' + yieldall end
        def e; 'e' end
      end

      mod.run.should == "(bdec)"
    end
    
    it "should yield options to all subsections" do
      mod = template(:e).new
      mod.sections :a, [:b, :c]
      class << mod
        def a; "(" + yieldall(:x => "2") + ")" end
        def b; @x end
        def c; @x end
      end
      mod.run.should == "(22)"
    end
    
    it "should yield all subsections more than once" do
      mod = template(:e).new
      mod.sections :a, [:b]
      class << mod
        def a; "(" + yieldall + yieldall + ")" end
        def b; "b" end
      end

      mod.run.should == "(bb)"
    end
    
    it "should not yield if no yieldall is called" do
      mod = template(:e).new
      mod.sections :a, [:b]
      class << mod
        def a; "()" end
        def b; "b" end
      end

      mod.run.should == "()"
    end
  end
end

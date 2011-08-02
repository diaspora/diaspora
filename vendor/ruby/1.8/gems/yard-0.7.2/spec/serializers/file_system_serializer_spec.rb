require File.join(File.dirname(__FILE__), "spec_helper")

require 'stringio'

describe YARD::Serializers::FileSystemSerializer do
  before do
    FileUtils.stub!(:mkdir_p)
    File.stub!(:open)
  end
  
  describe '#basepath' do
    it "should default the base path to the 'doc/'" do
      obj = Serializers::FileSystemSerializer.new
      obj.basepath.should == 'doc'
    end
  end

  describe '#extension' do
    it "should default the file extension to .html" do
      obj = Serializers::FileSystemSerializer.new
      obj.extension.should == "html"
    end
  end
  
  describe '#serialized_path' do
    it "should allow no extension to be used" do
      obj = Serializers::FileSystemSerializer.new :extension => nil
      yard = CodeObjects::ClassObject.new(nil, :FooBar)
      obj.serialized_path(yard).should == 'FooBar'
    end

    it "should serialize to top-level-namespace for root" do
      obj = Serializers::FileSystemSerializer.new :extension => nil
      obj.serialized_path(Registry.root).should == "top-level-namespace"
    end

    it "should return serialized_path for a String" do
      s = Serializers::FileSystemSerializer.new(:basepath => 'foo', :extension => 'txt')
      s.serialized_path('test.txt').should == 'test.txt'
    end
    
    it "should remove special chars from path" do
      m = CodeObjects::MethodObject.new(nil, 'a')
      s = Serializers::FileSystemSerializer.new

      { :/ => '_2F_i.html',
        :gsub! => 'gsub_21_i.html', 
        :ask? => 'ask_3F_i.html', 
        :=== => '_3D_3D_3D_i.html', 
        :+ => '_2B_i.html', 
        :- => '-_i.html', 
        :[]= => '_5B_5D_3D_i.html',
        :<< => '_3C_3C_i.html',
        :>= => '_3E_3D_i.html',
        :` => '_60_i.html',
        :& => '_26_i.html',
        :* => '_2A_i.html',
        :| => '_7C_i.html',
        :/ => '_2F_i.html',
        :=~ => '_3D_7E_i.html'
      }.each do |meth, value|
        m.stub!(:name).and_return(meth)
        s.serialized_path(m).should == value
      end
    end
    
    it "should handle ExtraFileObject's" do
      s = Serializers::FileSystemSerializer.new
      e = CodeObjects::ExtraFileObject.new('filename.txt', '')
      s.serialized_path(e).should == 'file.filename.html'
    end

    it "should differentiate instance and class methods from serialized path" do
      s = Serializers::FileSystemSerializer.new
      m1 = CodeObjects::MethodObject.new(nil, 'meth')
      m2 = CodeObjects::MethodObject.new(nil, 'meth', :class)
      s.serialized_path(m1).should_not == s.serialized_path(m2)
    end
    
    it "should serialize path from overload tag" do
      YARD.parse_string <<-'eof'
        class Foo
          # @overload bar
          def bar; end
        end
      eof
      
      serializer = Serializers::FileSystemSerializer.new
      object = Registry.at('Foo#bar').tag(:overload)
      serializer.serialized_path(object).should == "Foo/bar_i.html"
    end
  end
  
  describe '#serialize' do
    it "should serialize to the correct path" do
      yard = CodeObjects::ClassObject.new(nil, :FooBar)
      meth = CodeObjects::MethodObject.new(yard, :baz, :class)
      meth2 = CodeObjects::MethodObject.new(yard, :baz)

      { 'foo/FooBar/baz_c.txt' => meth,
        'foo/FooBar/baz_i.txt' => meth2,
        'foo/FooBar.txt' => yard }.each do |path, obj|
        io = StringIO.new
        File.should_receive(:open).with(path, 'wb').and_yield(io)
        io.should_receive(:write).with("data")

        s = Serializers::FileSystemSerializer.new(:basepath => 'foo', :extension => 'txt')
        s.serialize(obj, "data")
      end
    end

    it "should guarantee the directory exists" do
      o1 = CodeObjects::ClassObject.new(nil, :Really)
      o2 = CodeObjects::ClassObject.new(o1, :Long)
      o3 = CodeObjects::ClassObject.new(o2, :PathName)
      obj = CodeObjects::MethodObject.new(o3, :foo)

      FileUtils.should_receive(:mkdir_p).once.with('doc/Really/Long/PathName')

      s = Serializers::FileSystemSerializer.new
      s.serialize(obj, "data")
    end
  end
end
require File.join(File.dirname(__FILE__), "spec_helper")

describe YARD::RegistryStore do
  before do
    @store = RegistryStore.new
    @serializer = Serializers::YardocSerializer.new('foo')
    Serializers::YardocSerializer.stub!(:new).and_return(@serializer)
  end
  
  describe '#load' do
    it "should load root.dat as full object list if it is a Hash" do
      File.should_receive(:directory?).with('foo').and_return(true)
      File.should_receive(:file?).with('foo/checksums').and_return(false)
      File.should_receive(:file?).with('foo/proxy_types').and_return(false)
      @serializer.should_receive(:deserialize).with('root').and_return({:root => 'foo', :A => 'bar'})
      @store.load('foo').should == true
      @store.root.should == 'foo'
      @store.get('A').should == 'bar'
    end
    
    it "should load old yardoc format if .yardoc is a file" do
      File.should_receive(:directory?).with('foo').and_return(false)
      File.should_receive(:file?).with('foo').and_return(true)
      File.should_receive(:read_binary).with('foo').and_return('FOO')
      Marshal.should_receive(:load).with('FOO')

      @store.load('foo')
    end
    
    it "should load new yardoc format if .yardoc is a directory" do
      File.should_receive(:directory?).with('foo').and_return(true)
      File.should_receive(:file?).with('foo/checksums').and_return(false)
      File.should_receive(:file?).with('foo/proxy_types').and_return(false)
      File.should_receive(:file?).with('foo/objects/root.dat').and_return(false)

      @store.load('foo').should == true
    end
    
    it "should return true if .yardoc is loaded (file)" do
      File.should_receive(:directory?).with('myyardoc').and_return(false)
      File.should_receive(:file?).with('myyardoc').and_return(true)
      File.should_receive(:read_binary).with('myyardoc').and_return(Marshal.dump(''))
      @store.load('myyardoc').should == true
    end

    it "should return true if .yardoc is loaded (directory)" do
      File.should_receive(:directory?).with('foo').and_return(true)
      File.should_receive(:file?).with('foo/checksums').and_return(false)
      File.should_receive(:file?).with('foo/proxy_types').and_return(false)
      File.should_receive(:file?).with('foo/objects/root.dat').and_return(false)
      @store.load('foo').should == true
    end

    it "should return false if .yardoc does not exist" do
      @store.load('NONEXIST').should == false
    end
    
    it "should return false if there is no file to load" do
      @store.load(nil).should == false
    end
    
    it "should load checksums if they exist" do
      File.should_receive(:directory?).with('foo').and_return(true)
      File.should_receive(:file?).with('foo/checksums').and_return(true)
      File.should_receive(:file?).with('foo/proxy_types').and_return(false)
      File.should_receive(:file?).with('foo/objects/root.dat').and_return(false)
      File.should_receive(:readlines).with('foo/checksums').and_return([
        'file1 CHECKSUM1', '  file2 CHECKSUM2 '
      ])
      @store.load('foo').should == true
      @store.checksums.should == {'file1' => 'CHECKSUM1', 'file2' => 'CHECKSUM2'}
    end
    
    it "should load proxy_types if they exist" do
      File.should_receive(:directory?).with('foo').and_return(true)
      File.should_receive(:file?).with('foo/checksums').and_return(false)
      File.should_receive(:file?).with('foo/proxy_types').and_return(true)
      File.should_receive(:file?).with('foo/objects/root.dat').and_return(false)
      File.should_receive(:read_binary).with('foo/proxy_types').and_return(Marshal.dump({'a' => 'b'}))
      @store.load('foo').should == true
      @store.proxy_types.should == {'a' => 'b'}
    end

    it "should load root object if it exists" do
      File.should_receive(:directory?).with('foo').and_return(true)
      File.should_receive(:file?).with('foo/checksums').and_return(false)
      File.should_receive(:file?).with('foo/proxy_types').and_return(false)
      File.should_receive(:file?).with('foo/objects/root.dat').and_return(true)
      File.should_receive(:read_binary).with('foo/objects/root.dat').and_return(Marshal.dump('foo'))
      @store.load('foo').should == true
      @store.root.should == 'foo'
    end
  end
  
  describe '#save' do
    before do
      @store.stub!(:write_proxy_types)
      @store.stub!(:write_checksums)
      @store.stub!(:destroy)
    end
    
    after do
      Registry.single_object_db = nil
    end
    
    def saves_to_singledb
      @serializer.should_receive(:serialize).once.with(instance_of(Hash))
      @store.save(true, 'foo')
    end
    
    def add_items(n)
      n.times {|i| @store[i.to_s] = 'foo' }
    end
    
    def saves_to_multidb
      times = @store.keys.size
      @serializer.should_receive(:serialize).exactly(times).times
      @store.save(true, 'foo')
      @last = times
    end
    
    it "should save as single object db if single_object_db is nil and there are less than 3000 objects" do
      Registry.single_object_db = nil
      add_items(100)
      saves_to_singledb
    end
    
    it "should not save as single object db if single_object_db is nil and there are more than 3000 objects" do
      Registry.single_object_db = nil
      add_items(5000)
      saves_to_multidb
    end
    
    it "should save as single object db if single_object_db is true (and any amount of objects)" do
      Registry.single_object_db = true
      add_items(100)
      saves_to_singledb
      add_items(5000)
      saves_to_singledb
    end
    
    it "should never save as single object db if single_object_db is false" do
      Registry.single_object_db = false
      add_items(100)
      saves_to_multidb
      add_items(5000)
      saves_to_multidb
    end
  end
  
  describe '#put' do
    it "should assign values" do
      @store.put(:YARD, true)
      @store.get(:YARD).should == true
    end
    
    it "should treat '' as root" do
      @store.put('', 'value')
      @store.get(:root).should == 'value'
    end
  end
  
  describe '#get' do
    it "should hit cache if object exists" do
      @store.put(:YARD, true)
      @store.get(:YARD).should == true
    end
    
    it "should hit backstore on cache miss and cache is not fully loaded" do
      serializer = mock(:serializer)
      serializer.should_receive(:deserialize).once.with(:YARD).and_return('foo')
      @store.load('foo')
      @store.instance_variable_set("@loaded_objects", 0)
      @store.instance_variable_set("@available_objects", 100)
      @store.instance_variable_set("@serializer", serializer)
      @store.get(:YARD).should == 'foo'
      @store.get(:YARD).should == 'foo'
      @store.instance_variable_get("@loaded_objects").should == 1
    end
  end
  
  [:keys, :values].each do |item|
    describe "##{item}" do
      it "should load entire database if reload=true" do
        File.should_receive(:directory?).with('foo').and_return(true)
        @store.load('foo')
        @store.should_receive(:load_all)
        @store.send(item, true)
      end
    
      it "should not load entire database if reload=false" do
        File.should_receive(:directory?).with('foo').and_return(true)
        @store.load('foo')
        @store.should_not_receive(:load_all)
        @store.send(item, false)
      end
    end
  end
  
  describe '#load_all' do
    it "should load the entire database" do
      foomock = mock(:Foo)
      barmock = mock(:Bar)
      foomock.should_receive(:path).and_return('Foo')
      barmock.should_receive(:path).and_return('Bar')
      File.should_receive(:directory?).with('foo').and_return(true)
      File.should_receive(:file?).with('foo/proxy_types').and_return(false)
      File.should_receive(:file?).with('foo/checksums').and_return(false)
      File.should_receive(:file?).with('foo/objects/root.dat').and_return(false)
      @store.should_receive(:all_disk_objects).at_least(1).times.and_return(['foo/objects/foo', 'foo/objects/bar'])
      @store.load('foo')
      serializer = @store.instance_variable_get("@serializer")
      serializer.should_receive(:deserialize).with('foo/objects/foo', true).and_return(foomock)
      serializer.should_receive(:deserialize).with('foo/objects/bar', true).and_return(barmock)
      @store.send(:load_all)
      @store.instance_variable_get("@available_objects").should == 2
      @store.instance_variable_get("@loaded_objects").should == 2
      @store[:Foo].should == foomock
      @store[:Bar].should == barmock
    end
  end
  
  describe '#destroy' do
    it "should destroy file ending in .yardoc when force=false" do
      File.should_receive(:file?).with('foo.yardoc').and_return(true)
      File.should_receive(:unlink).with('foo.yardoc')
      @store.instance_variable_set("@file", 'foo.yardoc')
      @store.destroy.should == true
    end

    it "should destroy dir ending in .yardoc when force=false" do
      File.should_receive(:directory?).with('foo.yardoc').and_return(true)
      FileUtils.should_receive(:rm_rf).with('foo.yardoc')
      @store.instance_variable_set("@file", 'foo.yardoc')
      @store.destroy.should == true
    end

    it "should not destroy file/dir not ending in .yardoc when force=false" do
      File.should_not_receive(:file?).with('foo')
      File.should_not_receive(:directory?).with('foo')
      File.should_not_receive(:unlink).with('foo')
      FileUtils.should_not_receive(:rm_rf).with('foo')
      @store.instance_variable_set("@file", 'foo')
      @store.destroy.should == false
    end
    
    it "should destroy any file/dir when force=true" do
      File.should_receive(:file?).with('foo').and_return(true)
      File.should_receive(:unlink).with('foo')
      @store.instance_variable_set("@file", 'foo')
      @store.destroy(true).should == true
    end
  end
end
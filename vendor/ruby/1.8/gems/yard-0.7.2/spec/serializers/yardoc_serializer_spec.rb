require File.dirname(__FILE__) + "/spec_helper"

instance_eval do
  class YARD::Serializers::YardocSerializer
    public :dump
    public :internal_dump
  end
end

describe YARD::Serializers::YardocSerializer do
  before do
    @serializer = YARD::Serializers::YardocSerializer.new('.yardoc')

    Registry.clear
    @foo = CodeObjects::ClassObject.new(:root, :Foo)
    @bar = CodeObjects::MethodObject.new(@foo, :bar)
  end

  describe '#dump' do
    it "should maintain object equality when loading a dumped object" do
      newfoo = @serializer.internal_dump(@foo)
      newfoo.should equal(@foo)
      newfoo.should == @foo
      @foo.should equal(newfoo)
      @foo.should == newfoo
      newfoo.hash.should == @foo.hash
    end
    
    it "should maintain hash key equality when loading a dumped object" do
      newfoo = @serializer.internal_dump(@foo)
      {@foo => 1}.should have_key(newfoo)
      {newfoo => 1}.should have_key(@foo)
    end
  end
  
  describe '#serialize' do
    it "should accept a hash of codeobjects (and write to root)" do
      data = {:root => Registry.root}
      marshaldata = Marshal.dump(data)
      filemock = mock(:file)
      filemock.should_receive(:write).with(marshaldata)
      File.should_receive(:open!).with('.yardoc/objects/root.dat', 'wb').and_yield(filemock)
      @serializer.serialize(data)
    end
  end
end
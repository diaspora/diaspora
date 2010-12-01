require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

module LibTest
  Types = {
    's8' => [:char, :c, 1],
    's16' => [:short, :s, 0xff0], 
    's32' => [:int, :i, 0xff00],
    's64' => [:long_long, :j, 0xffff00],
    'long' => [:long, :l, 0xffff],
    'f32' => [:float, :f, 1.0001],
    'f64' => [:double, :d, 1.000000001]
  }
  class TestUnion < FFI::Union
    layout( :a, [:char, 10], 
            :i, :int, 
            :f, :float,
            :d, :double,
            :s, :short,
            :l, :long,
            :j, :long_long,
            :c, :char )
  end
  Types.keys.each do |k| 
    attach_function "union_align_#{k}", [ :pointer ], Types[k][0]
    attach_function "union_make_union_with_#{k}", [ Types[k][0] ], :pointer
  end
  attach_function :union_size, [], :uint
end

describe 'Union' do
  before do
    @u = LibTest::TestUnion.new
  end
  it 'should place all the fields at offset 0' do
    LibTest::TestUnion.members.all? { |m| LibTest::TestUnion.offset_of(m) == 0 }.should be_true
  end
  LibTest::Types.each do |k, type|
    it "should correctly align/write a #{type[0]} value" do
      @u[type[1]] = type[2]
      if k == 'f32' or k == 'f64'
        (@u[type[1]] - LibTest.send("union_align_#{k}", @u.to_ptr)).abs.should < 0.00001
      else
        @u[type[1]].should == LibTest.send("union_align_#{k}", @u.to_ptr)
      end
    end
  end
  LibTest::Types.each do |k, type|
    it "should read a #{type[0]} value from memory" do
      @u = LibTest::TestUnion.new(LibTest.send("union_make_union_with_#{k}", type[2]))
      if k == 'f32' or k == 'f64'
        (@u[type[1]] - type[2]).abs.should < 0.00001
      else
        @u[type[1]].should == type[2]
      end
    end
  end
  it 'should return a size equals to the size of the biggest field' do
    LibTest::TestUnion.size.should == LibTest.union_size
  end
end

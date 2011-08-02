require 'spec_helper'

describe "should include(expected)" do
  context "for a string target" do
    it "passes if target includes expected" do
      "abc".should include("a")
    end

    it "fails if target does not include expected" do
      lambda {
        "abc".should include("d")
      }.should fail_with("expected \"abc\" to include \"d\"")
    end
  end

  context "for an array target" do
    it "passes if target includes expected" do
      [1,2,3].should include(3)
    end

    it "fails if target does not include expected" do
      lambda {
        [1,2,3].should include(4)
      }.should fail_with("expected [1, 2, 3] to include 4")
    end
  end

  context "for a hash target" do
    it 'passes if target has the expected as a key' do
      {:key => 'value'}.should include(:key)
    end

    it "fails if target does not include expected" do
      lambda {
        {:key => 'value'}.should include(:other)
      }.should fail_matching(%Q|expected {:key=>"value"} to include :other|)
    end
  end
end

describe "should include(with, multiple, args)" do
  context "for a string target" do
    it "passes if target includes all items" do
      "a string".should include("str", "a")
    end

    it "fails if target does not include any one of the items" do
      lambda {
        "a string".should include("str", "a", "foo")
      }.should fail_with(%Q{expected "a string" to include "str", "a", and "foo"})
    end
  end

  context "for an array target" do
    it "passes if target includes all items" do
      [1,2,3].should include(1,2,3)
    end

    it "fails if target does not include any one of the items" do
      lambda {
        [1,2,3].should include(1,2,4)
      }.should fail_with("expected [1, 2, 3] to include 1, 2, and 4")
    end
  end

  context "for a hash target" do
    it 'passes if target includes all items as keys' do
      {:key => 'value', :other => 'value'}.should include(:key, :other)
    end

    it 'fails if target is missing any item as a key' do
      lambda {
        {:key => 'value'}.should include(:key, :other)
      }.should fail_matching(%Q|expected {:key=>"value"} to include :key and :other|)
    end
  end
end

describe "should_not include(expected)" do
  context "for a string target" do
    it "passes if target does not include expected" do
      "abc".should_not include("d")
    end

    it "fails if target includes expected" do
      lambda {
        "abc".should_not include("c")
      }.should fail_with("expected \"abc\" not to include \"c\"")
    end
  end

  context "for an array target" do
    it "passes if target does not include expected" do
      [1,2,3].should_not include(4)
    end

    it "fails if target includes expected" do
      lambda {
        [1,2,3].should_not include(3)
      }.should fail_with("expected [1, 2, 3] not to include 3")
    end
  end

  context "for a hash target" do
    it 'passes if target does not have the expected as a key' do
      {:other => 'value'}.should_not include(:key)
    end

    it "fails if target includes expected key" do
      lambda {
        {:key => 'value'}.should_not include(:key)
      }.should fail_matching(%Q|expected {:key=>"value"} not to include :key|)
    end
  end

end

describe "should_not include(with, multiple, args)" do
  context "for a string target" do
    it "passes if the target does not include any of the expected" do
      "abc".should_not include("d", "e", "f")
    end

    it "fails if the target includes all of the expected" do
      expect {
        "abc".should_not include("c", "a")
      }.to fail_with(%q{expected "abc" not to include "c" and "a"})
    end

    it "fails if the target includes some (but not all) of the expected" do
      expect {
        "abc".should_not include("d", "a")
      }.to fail_with(%q{expected "abc" not to include "d" and "a"})
    end
  end

  context "for a hash target" do
    it "passes if it does not include any of the expected keys" do
      { :a => 1, :b => 2 }.should_not include(:c, :d)
    end

    it "fails if the target includes all of the expected keys" do
      expect {
        { :a => 1, :b => 2 }.should_not include(:a, :b)
      }.to fail_matching(%Q|expected #{{:a=>1, :b=>2}.inspect} not to include :a and :b|)
    end

    it "fails if the target includes some (but not all) of the expected keys" do
      expect {
        { :a => 1, :b => 2 }.should_not include(:d, :b)
      }.to fail_matching(%Q|expected #{{:a=>1, :b=>2}.inspect} not to include :d and :b|)
    end
  end

  context "for an array target" do
    it "passes if the target does not include any of the expected" do
      [1, 2, 3].should_not include(4, 5, 6)
    end

    it "fails if the target includes all of the expected" do
      expect {
        [1, 2, 3].should_not include(3, 1)
      }.to fail_with(%q{expected [1, 2, 3] not to include 3 and 1})
    end

    it "fails if the target includes some (but not all) of the expected" do
      expect {
        [1, 2, 3].should_not include(4, 1)
      }.to fail_with(%q{expected [1, 2, 3] not to include 4 and 1})
    end
  end
end

describe "should include(:key => value)" do
  context 'for a hash target' do
    it "passes if target includes the key/value pair" do
      {:key => 'value'}.should include(:key => 'value')
    end

    it "passes if target includes the key/value pair among others" do
      {:key => 'value', :other => 'different'}.should include(:key => 'value')
    end

    it "fails if target has a different value for key" do
      lambda {
        {:key => 'different'}.should include(:key => 'value')
      }.should fail_matching(%Q|expected {:key=>"different"} to include {:key=>"value"}|)
    end

    it "fails if target has a different key" do
      lambda {
        {:other => 'value'}.should include(:key => 'value')
      }.should fail_matching(%Q|expected {:other=>"value"} to include {:key=>"value"}|)
    end
  end

  context 'for a non-hash target' do
    it "fails if the target does not contain the given hash" do
      lambda {
        ['a', 'b'].should include(:key => 'value')
      }.should fail_matching(%q|expected ["a", "b"] to include {:key=>"value"}|)
    end

    it "passes if the target contains the given hash" do
      ['a', { :key => 'value' } ].should include(:key => 'value')
    end
  end
end

describe "should_not include(:key => value)" do
  context 'for a hash target' do
    it "fails if target includes the key/value pair" do
      lambda {
        {:key => 'value'}.should_not include(:key => 'value')
      }.should fail_matching(%Q|expected {:key=>"value"} not to include {:key=>"value"}|)
    end

    it "fails if target includes the key/value pair among others" do
      lambda {
        {:key => 'value', :other => 'different'}.should_not include(:key => 'value')
      }.should fail_matching(%Q|expected #{{:key=>"value", :other=>"different"}.inspect} not to include {:key=>"value"}|)
    end

    it "passes if target has a different value for key" do
      {:key => 'different'}.should_not include(:key => 'value')
    end

    it "passes if target has a different key" do
      {:other => 'value'}.should_not include(:key => 'value')
    end
  end

  context "for a non-hash target" do
    it "passes if the target does not contain the given hash" do
      ['a', 'b'].should_not include(:key => 'value')
    end

    it "fails if the target contains the given hash" do
      lambda {
        ['a', { :key => 'value' } ].should_not include(:key => 'value')
      }.should fail_matching(%Q|expected ["a", {:key=>"value"}] not to include {:key=>"value"}|)
    end
  end
end

describe "should include(:key1 => value1, :key2 => value2)" do
  context 'for a hash target' do
    it "passes if target includes the key/value pairs" do
      {:a => 1, :b => 2}.should include(:b => 2, :a => 1)
    end

    it "passes if target includes the key/value pairs among others" do
      {:a => 1, :c => 3, :b => 2}.should include(:b => 2, :a => 1)
    end

    it "fails if target has a different value for one of the keys" do
      lambda {
        {:a => 1, :b => 2}.should include(:a => 2, :b => 2)
      }.should fail_matching(%Q|expected #{{:a=>1, :b=>2}.inspect} to include #{{:a=>2, :b=>2}.inspect}|)
    end

    it "fails if target has a different value for both of the keys" do
      lambda {
        {:a => 1, :b => 1}.should include(:a => 2, :b => 2)
      }.should fail_matching(%Q|expected #{{:a=>1, :b=>1}.inspect} to include #{{:a=>2, :b=>2}.inspect}|)
    end

    it "fails if target lacks one of the keys" do
      lambda {
        {:a => 1, :b => 1}.should include(:a => 1, :c => 1)
      }.should fail_matching(%Q|expected #{{:a=>1, :b=>1}.inspect} to include #{{:a=>1, :c=>1}.inspect}|)
    end

    it "fails if target lacks both of the keys" do
      lambda {
        {:a => 1, :b => 1}.should include(:c => 1, :d => 1)
      }.should fail_matching(%Q|expected #{{:a=>1, :b=>1}.inspect} to include #{{:c=>1, :d=>1}.inspect}|)
    end
  end

  context 'for a non-hash target' do
    it "fails if the target does not contain the given hash" do
      lambda {
        ['a', 'b'].should include(:a => 1, :b => 1)
      }.should fail_matching(%Q|expected ["a", "b"] to include #{{:a=>1, :b=>1}.inspect}|)
    end

    it "passes if the target contains the given hash" do
      ['a', { :a => 1, :b => 2 } ].should include(:a => 1, :b => 2)
    end
  end
end

describe "should_not include(:key1 => value1, :key2 => value2)" do
  context 'for a hash target' do
    it "fails if target includes the key/value pairs" do
      lambda {
        {:a => 1, :b => 2}.should_not include(:a => 1, :b => 2)
      }.should fail_matching(%Q|expected #{{:a=>1, :b=>2}.inspect} not to include #{{:a=>1, :b=>2}.inspect}|)
    end

    it "fails if target includes the key/value pairs among others" do
      hash = {:a => 1, :b => 2, :c => 3}
      lambda {
        hash.should_not include(:a => 1, :b => 2)
      }.should fail_matching(%Q|expected #{hash.inspect} not to include #{{:a=>1, :b=>2}.inspect}|)
    end

    it "fails if target has a different value for one of the keys" do
      lambda {
        {:a => 1, :b => 2}.should_not include(:a => 2, :b => 2)
      }.should fail_matching(%Q|expected #{{:a=>1, :b=>2}.inspect} not to include #{{:a=>2, :b=>2}.inspect}|)
    end

    it "passes if target has a different value for both of the keys" do
      {:a => 1, :b => 1}.should_not include(:a => 2, :b => 2)
    end

    it "fails if target lacks one of the keys" do
      lambda {
        {:a => 1, :b => 1}.should_not include(:a => 1, :c => 1)
      }.should fail_matching(%Q|expected #{{:a=>1, :b=>1}.inspect} not to include #{{:a=>1, :c=>1}.inspect}|)
    end

    it "passes if target lacks both of the keys" do
      {:a => 1, :b => 1}.should_not include(:c => 1, :d => 1)
    end
  end

  context 'for a non-hash target' do
    it "passes if the target does not contain the given hash" do
      ['a', 'b'].should_not include(:a => 1, :b => 1)
    end

    it "fails if the target contains the given hash" do
      lambda {
        ['a', { :a => 1, :b => 2 } ].should_not include(:a => 1, :b => 2)
      }.should fail_matching(%Q|expected #{["a", {:a=>1, :b=>2}].inspect} not to include #{{:a=>1, :b=>2}.inspect}|)
    end
  end
end

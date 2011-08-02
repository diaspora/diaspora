require 'spec_helper'

describe Hashie::Mash do
  before(:each) do
    @mash = Hashie::Mash.new
  end

  it "should inherit from hash" do
    @mash.is_a?(Hash).should be_true
  end

  it "should be able to set hash values through method= calls" do
    @mash.test = "abc"
    @mash["test"].should == "abc"
  end

  it "should be able to retrieve set values through method calls" do
    @mash["test"] = "abc"
    @mash.test.should == "abc"
  end
  
  it "should be able to retrieve set values through blocks" do
    @mash["test"] = "abc"
    value = nil
    @mash.[]("test") { |v| value = v }
    value.should == "abc"
  end
  
  it "should be able to retrieve set values through blocks with method calls" do
    @mash["test"] = "abc"
    value = nil
    @mash.test { |v| value = v }
    value.should == "abc"
  end

  it "should test for already set values when passed a ? method" do
    @mash.test?.should be_false
    @mash.test = "abc"
    @mash.test?.should be_true
  end
  
  it "should return false on a ? method if a value has been set to nil or false" do
    @mash.test = nil
    @mash.should_not be_test
    @mash.test = false
    @mash.should_not be_test
  end

  it "should make all [] and []= into strings for consistency" do
    @mash["abc"] = 123
    @mash.key?('abc').should be_true
    @mash["abc"].should == 123
  end

  it "should have a to_s that is identical to its inspect" do
    @mash.abc = 123
    @mash.to_s.should == @mash.inspect
  end

  it "should return nil instead of raising an error for attribute-esque method calls" do
    @mash.abc.should be_nil
  end

  it "should return a Hashie::Mash when passed a bang method to a non-existenct key" do
    @mash.abc!.is_a?(Hashie::Mash).should be_true
  end

  it "should return the existing value when passed a bang method for an existing key" do
    @mash.name = "Bob"
    @mash.name!.should == "Bob"
  end

  it "#initializing_reader should return a Hashie::Mash when passed a non-existent key" do
    @mash.initializing_reader(:abc).is_a?(Hashie::Mash).should be_true
  end

  it "should allow for multi-level assignment through bang methods" do
    @mash.author!.name = "Michael Bleigh"
    @mash.author.should == Hashie::Mash.new(:name => "Michael Bleigh")
    @mash.author!.website!.url = "http://www.mbleigh.com/"
    @mash.author.website.should == Hashie::Mash.new(:url => "http://www.mbleigh.com/")
  end

  context "updating" do
    subject {
      described_class.new :first_name => "Michael", :last_name => "Bleigh",
        :details => {:email => "michael@asf.com", :address => "Nowhere road"}
    }

    describe "#deep_update" do
      it "should recursively Hashie::Mash Hashie::Mashes and hashes together" do
        subject.deep_update(:details => {:email => "michael@intridea.com", :city => "Imagineton"})
        subject.first_name.should == "Michael"
        subject.details.email.should == "michael@intridea.com"
        subject.details.address.should == "Nowhere road"
        subject.details.city.should == "Imagineton"
      end
  
      it "should make #update deep by default" do
        subject.update(:details => {:address => "Fake street"}).should eql(subject)
        subject.details.address.should == "Fake street"
        subject.details.email.should == "michael@asf.com"
      end
    
      it "should clone before a #deep_merge" do
        duped = subject.deep_merge(:details => {:address => "Fake street"})
        duped.should_not eql(subject)
        duped.details.address.should == "Fake street"
        subject.details.address.should == "Nowhere road"
        duped.details.email.should == "michael@asf.com"
      end
    
      it "regular #merge should be deep" do
        duped = subject.merge(:details => {:email => "michael@intridea.com"})
        duped.should_not eql(subject)
        duped.details.email.should == "michael@intridea.com"
        duped.details.address.should == "Nowhere road"
      end
    end

    describe "shallow update" do
      it "should shallowly Hashie::Mash Hashie::Mashes and hashes together" do
        subject.shallow_update(:details => {
          :email => "michael@intridea.com", :city => "Imagineton"
        }).should eql(subject)
        
        subject.first_name.should == "Michael"
        subject.details.email.should == "michael@intridea.com"
        subject.details.address.should be_nil
        subject.details.city.should == "Imagineton"
      end
  
      it "should clone before a #regular_merge" do
        duped = subject.shallow_merge(:details => {:address => "Fake street"})
        duped.should_not eql(subject)
      end
    
      it "regular merge should be shallow" do
        duped = subject.shallow_merge(:details => {:address => "Fake street"})
        duped.details.address.should == "Fake street"
        subject.details.address.should == "Nowhere road"
        duped.details.email.should be_nil
      end
    end

    describe 'delete' do
      it 'should delete with String key' do
        subject.delete('details')
        subject.details.should be_nil
        subject.should_not be_respond_to :details
      end

      it 'should delete with Symbol key' do
        subject.delete(:details)
        subject.details.should be_nil
        subject.should_not be_respond_to :details
      end
    end
  end

  it "should convert hash assignments into Hashie::Mashes" do
    @mash.details = {:email => 'randy@asf.com', :address => {:state => 'TX'} }
    @mash.details.email.should == 'randy@asf.com'
    @mash.details.address.state.should == 'TX'
  end

  it "should not convert the type of Hashie::Mashes childs to Hashie::Mash" do
    class MyMash < Hashie::Mash
    end

    record = MyMash.new
    record.son = MyMash.new
    record.son.class.should == MyMash
  end
  
  it "should not change the class of Mashes when converted" do
    class SubMash < Hashie::Mash
    end
    
    record = Hashie::Mash.new
    son = SubMash.new
    record['submash'] = son
    record['submash'].should be_kind_of(SubMash)
  end
  
  it "should respect the class when passed a bang method for a non-existent key" do
    record = Hashie::Mash.new
    record.non_existent!.should be_kind_of(Hashie::Mash)
    
    class SubMash < Hashie::Mash
    end
    
    son = SubMash.new
    son.non_existent!.should be_kind_of(SubMash)
  end
  
  it "should respect the class when converting the value" do
    record = Hashie::Mash.new
    record.details = Hashie::Mash.new({:email => "randy@asf.com"})
    record.details.should be_kind_of(Hashie::Mash)
    
    class SubMash < Hashie::Mash
    end
    
    son = SubMash.new
    son.details = Hashie::Mash.new({:email => "randyjr@asf.com"})
    son.details.should be_kind_of(SubMash)
  end
  
  describe '#respond_to?' do
    it 'should respond to a normal method' do
      Hashie::Mash.new.should be_respond_to(:key?)
    end
    
    it 'should respond to a set key' do
      Hashie::Mash.new(:abc => 'def').should be_respond_to(:abc)
    end
  end

  context "#initialize" do
    it "should convert an existing hash to a Hashie::Mash" do
      converted = Hashie::Mash.new({:abc => 123, :name => "Bob"})
      converted.abc.should == 123
      converted.name.should == "Bob"
    end

    it "should convert hashes recursively into Hashie::Mashes" do
      converted = Hashie::Mash.new({:a => {:b => 1, :c => {:d => 23}}})
      converted.a.is_a?(Hashie::Mash).should be_true
      converted.a.b.should == 1
      converted.a.c.d.should == 23
    end

    it "should convert hashes in arrays into Hashie::Mashes" do
      converted = Hashie::Mash.new({:a => [{:b => 12}, 23]})
      converted.a.first.b.should == 12
      converted.a.last.should == 23
    end

    it "should convert an existing Hashie::Mash into a Hashie::Mash" do
      initial = Hashie::Mash.new(:name => 'randy', :address => {:state => 'TX'})
      copy = Hashie::Mash.new(initial)
      initial.name.should == copy.name
      initial.object_id.should_not == copy.object_id
      copy.address.state.should == 'TX'
      copy.address.state = 'MI'
      initial.address.state.should == 'TX'
      copy.address.object_id.should_not == initial.address.object_id
    end

    it "should accept a default block" do
      initial = Hashie::Mash.new { |h,i| h[i] = []}
      initial.default_proc.should_not be_nil
      initial.default.should be_nil
      initial.test.should == []
      initial.test?.should be_true
    end

    describe "to_json" do

      it "should render to_json" do
        @mash.foo = :bar
        @mash.bar = {"homer" => "simpson"}
        expected = {"foo" => "bar", "bar" => {"homer" => "simpson"}}
        JSON.parse(@mash.to_json).should == expected
      end
    end
  end
end

require 'spec_helper'

describe OrmAdapter::Base do
  subject { OrmAdapter::Base.new(Object) }
  
  describe "#extract_conditions_and_order!" do
    let(:conditions) { {:foo => 'bar'} }
    let(:order) { [[:foo, :asc]] }
    
    it "(<conditions>) should return [<conditions>, []]" do
      subject.send(:extract_conditions_and_order!, conditions).should == [conditions, []]
    end
    
    it "(:conditions => <conditions>) should return [<conditions>, []]" do
      subject.send(:extract_conditions_and_order!, :conditions => conditions).should == [conditions, []]
    end

    it "(:order => <order>) should return [{}, <order>]" do
      subject.send(:extract_conditions_and_order!, :order => order).should == [{}, order]
    end
    
    it "(:conditions => <conditions>, :order => <order>) should return [<conditions>, <order>]" do
      subject.send(:extract_conditions_and_order!, :conditions => conditions, :order => order).should == [conditions, order]
    end
    
    describe "#normalize_order" do
      specify "(nil) returns []" do
        subject.send(:normalize_order, nil).should == []
      end
      
      specify ":foo returns [[:foo, :asc]]" do
        subject.send(:normalize_order, :foo).should == [[:foo, :asc]]
      end
      
      specify "[:foo] returns [[:foo, :asc]]" do
        subject.send(:normalize_order, [:foo]).should == [[:foo, :asc]]
      end
      
      specify "[:foo, :desc] returns [[:foo, :desc]]" do
        subject.send(:normalize_order, [:foo, :desc]).should == [[:foo, :desc]]
      end
      
      specify "[:foo, [:bar, :asc], [:baz, :desc], :bing] returns [[:foo, :asc], [:bar, :asc], [:baz, :desc], [:bing, :asc]]" do
        subject.send(:normalize_order, [:foo, [:bar, :asc], [:baz, :desc], :bing]).should == [[:foo, :asc], [:bar, :asc], [:baz, :desc], [:bing, :asc]]
      end
      
      specify "[[:foo, :wtf]] raises ArgumentError" do
        lambda { subject.send(:normalize_order, [[:foo, :wtf]]) }.should raise_error(ArgumentError)
      end
      
      specify "[[:foo, :asc, :desc]] raises ArgumentError" do
        lambda { subject.send(:normalize_order, [[:foo, :asc, :desc]]) }.should raise_error(ArgumentError)
      end
    end
  end
end

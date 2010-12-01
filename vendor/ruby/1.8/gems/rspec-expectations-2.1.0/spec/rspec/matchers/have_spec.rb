require 'spec_helper'
require 'stringio'

describe "have matcher" do

  before(:each) do
    if defined?(::ActiveSupport::Inflector) && ::ActiveSupport::Inflector.respond_to?(:pluralize)
      @active_support_was_defined = true
    else
      @active_support_was_defined = false
      module ::ActiveSupport
        class Inflector
          def self.pluralize(string)
            string.to_s + 's'
          end
        end
      end
    end
  end

  def create_collection_owner_with(n)
    owner = RSpec::Expectations::Helper::CollectionOwner.new
    (1..n).each do |number|
      owner.add_to_collection_with_length_method(number)
      owner.add_to_collection_with_size_method(number)
    end
    owner
  end

describe "should have(n).items" do

  it "passes if target has a collection of items with n members" do
    owner = create_collection_owner_with(3)
    owner.should have(3).items_in_collection_with_length_method
    owner.should have(3).items_in_collection_with_size_method
  end

  it "converts :no to 0" do
    owner = create_collection_owner_with(0)
    owner.should have(:no).items_in_collection_with_length_method
    owner.should have(:no).items_in_collection_with_size_method
  end

  it "fails if target has a collection of items with < n members" do
    owner = create_collection_owner_with(3)
    lambda {
      owner.should have(4).items_in_collection_with_length_method
    }.should fail_with("expected 4 items_in_collection_with_length_method, got 3")
    lambda {
      owner.should have(4).items_in_collection_with_size_method
    }.should fail_with("expected 4 items_in_collection_with_size_method, got 3")
  end
  
  it "fails if target has a collection of items with > n members" do
    owner = create_collection_owner_with(3)
    lambda {
      owner.should have(2).items_in_collection_with_length_method
    }.should fail_with("expected 2 items_in_collection_with_length_method, got 3")
    lambda {
      owner.should have(2).items_in_collection_with_size_method
    }.should fail_with("expected 2 items_in_collection_with_size_method, got 3")
  end
end

describe 'should have(1).item when ActiveSupport::Inflector is defined' do
  
  it 'pluralizes the collection name' do
    owner = create_collection_owner_with(1)
    owner.should have(1).item
  end

  context "when ActiveSupport::Inflector is partially loaded without its inflectors" do

    it "does not pluralize the collection name" do
      (class << ::ActiveSupport::Inflector; self; end).send :undef_method, :pluralize
      owner = create_collection_owner_with(1)
      expect { owner.should have(1).item }.to raise_error(NoMethodError)
    end

  end
  
  after(:each) do
    unless @active_support_was_defined
      Object.__send__ :remove_const, :ActiveSupport
    end
  end
end

describe 'should have(1).item when Inflector is defined' do
  
  before(:each) do
    if defined?(Inflector)
      @inflector_was_defined = true
    else
      @inflector_was_defined = false
      class ::Inflector
        def self.pluralize(string)
          string.to_s + 's'
        end
      end
    end
  end
  
  it 'pluralizes the collection name' do
    owner = create_collection_owner_with(1)
    owner.should have(1).item
  end

  after(:each) do
    unless @inflector_was_defined
      Object.__send__ :remove_const, :Inflector
    end
  end
end

describe "should have(n).items where result responds to items but returns something other than a collection" do
  it "provides a meaningful error" do
    owner = Class.new do
      def items
        Object.new
      end
    end.new
    lambda do
      owner.should have(3).items
    end.should raise_error("expected items to be a collection but it does not respond to #length or #size")
  end
end

describe "should_not have(n).items" do

  it "passes if target has a collection of items with < n members" do
    owner = create_collection_owner_with(3)
    owner.should_not have(4).items_in_collection_with_length_method
    owner.should_not have(4).items_in_collection_with_size_method
  end
  
  it "passes if target has a collection of items with > n members" do
    owner = create_collection_owner_with(3)
    owner.should_not have(2).items_in_collection_with_length_method
    owner.should_not have(2).items_in_collection_with_size_method
  end

  it "fails if target has a collection of items with n members" do
    owner = create_collection_owner_with(3)
    lambda {
      owner.should_not have(3).items_in_collection_with_length_method
    }.should fail_with("expected target not to have 3 items_in_collection_with_length_method, got 3")
    lambda {
      owner.should_not have(3).items_in_collection_with_size_method
      }.should fail_with("expected target not to have 3 items_in_collection_with_size_method, got 3")
  end
end

describe "should have_exactly(n).items" do

  it "passes if target has a collection of items with n members" do
    owner = create_collection_owner_with(3)
    owner.should have_exactly(3).items_in_collection_with_length_method
    owner.should have_exactly(3).items_in_collection_with_size_method
  end

  it "converts :no to 0" do
    owner = create_collection_owner_with(0)
    owner.should have_exactly(:no).items_in_collection_with_length_method
    owner.should have_exactly(:no).items_in_collection_with_size_method
  end

  it "fails if target has a collection of items with < n members" do
    owner = create_collection_owner_with(3)
    lambda {
      owner.should have_exactly(4).items_in_collection_with_length_method
    }.should fail_with("expected 4 items_in_collection_with_length_method, got 3")
    lambda {
      owner.should have_exactly(4).items_in_collection_with_size_method
    }.should fail_with("expected 4 items_in_collection_with_size_method, got 3")
  end
  
  it "fails if target has a collection of items with > n members" do
    owner = create_collection_owner_with(3)
    lambda {
      owner.should have_exactly(2).items_in_collection_with_length_method
    }.should fail_with("expected 2 items_in_collection_with_length_method, got 3")
    lambda {
      owner.should have_exactly(2).items_in_collection_with_size_method
    }.should fail_with("expected 2 items_in_collection_with_size_method, got 3")
  end
end

describe "should have_at_least(n).items" do

  it "passes if target has a collection of items with n members" do
    owner = create_collection_owner_with(3)
    owner.should have_at_least(3).items_in_collection_with_length_method
    owner.should have_at_least(3).items_in_collection_with_size_method
  end
  
  it "passes if target has a collection of items with > n members" do
    owner = create_collection_owner_with(3)
    owner.should have_at_least(2).items_in_collection_with_length_method
    owner.should have_at_least(2).items_in_collection_with_size_method
  end

  it "fails if target has a collection of items with < n members" do
    owner = create_collection_owner_with(3)
    lambda {
      owner.should have_at_least(4).items_in_collection_with_length_method
    }.should fail_with("expected at least 4 items_in_collection_with_length_method, got 3")
    lambda {
      owner.should have_at_least(4).items_in_collection_with_size_method
    }.should fail_with("expected at least 4 items_in_collection_with_size_method, got 3")
  end
  
  it "provides educational negative failure messages" do
    #given
    owner = create_collection_owner_with(3)
    length_matcher = have_at_least(3).items_in_collection_with_length_method
    size_matcher = have_at_least(3).items_in_collection_with_size_method
    
    #when
    length_matcher.matches?(owner)
    size_matcher.matches?(owner)
    
    #then
    length_matcher.failure_message_for_should_not.should == <<-EOF
Isn't life confusing enough?
Instead of having to figure out the meaning of this:
  should_not have_at_least(3).items_in_collection_with_length_method
We recommend that you use this instead:
  should have_at_most(2).items_in_collection_with_length_method
EOF

    size_matcher.failure_message_for_should_not.should == <<-EOF
Isn't life confusing enough?
Instead of having to figure out the meaning of this:
  should_not have_at_least(3).items_in_collection_with_size_method
We recommend that you use this instead:
  should have_at_most(2).items_in_collection_with_size_method
EOF
  end
end

describe "should have_at_most(n).items" do
  it "passes if target has a collection of items with n members" do
    owner = create_collection_owner_with(3)
    owner.should have_at_most(3).items_in_collection_with_length_method
    owner.should have_at_most(3).items_in_collection_with_size_method
  end

  it "fails if target has a collection of items with > n members" do
    owner = create_collection_owner_with(3)
    lambda {
      owner.should have_at_most(2).items_in_collection_with_length_method
    }.should fail_with("expected at most 2 items_in_collection_with_length_method, got 3")
    lambda {
      owner.should have_at_most(2).items_in_collection_with_size_method
    }.should fail_with("expected at most 2 items_in_collection_with_size_method, got 3")
  end
  
  it "passes if target has a collection of items with < n members" do
    owner = create_collection_owner_with(3)
    owner.should have_at_most(4).items_in_collection_with_length_method
    owner.should have_at_most(4).items_in_collection_with_size_method
  end

  it "provides educational negative failure messages" do
    #given
    owner = create_collection_owner_with(3)
    length_matcher = have_at_most(3).items_in_collection_with_length_method
    size_matcher = have_at_most(3).items_in_collection_with_size_method
    
    #when
    length_matcher.matches?(owner)
    size_matcher.matches?(owner)
    
    #then
    length_matcher.failure_message_for_should_not.should == <<-EOF
Isn't life confusing enough?
Instead of having to figure out the meaning of this:
  should_not have_at_most(3).items_in_collection_with_length_method
We recommend that you use this instead:
  should have_at_least(4).items_in_collection_with_length_method
EOF
    
    size_matcher.failure_message_for_should_not.should == <<-EOF
Isn't life confusing enough?
Instead of having to figure out the meaning of this:
  should_not have_at_most(3).items_in_collection_with_size_method
We recommend that you use this instead:
  should have_at_least(4).items_in_collection_with_size_method
EOF
  end
end

describe "have(n).items(args, block)" do
  it "passes args to target" do
    target = mock("target")
    target.should_receive(:items).with("arg1","arg2").and_return([1,2,3])
    target.should have(3).items("arg1","arg2")
  end

  it "passes block to target" do
    target = mock("target")
    block = lambda { 5 }
    target.should_receive(:items).with("arg1","arg2", block).and_return([1,2,3])
    target.should have(3).items("arg1","arg2", block)
  end
end

describe "have(n).items where target IS a collection" do
  it "references the number of items IN the collection" do
    [1,2,3].should have(3).items
  end

  it "fails when the number of items IN the collection is not as expected" do
    lambda { [1,2,3].should have(7).items }.should fail_with("expected 7 items, got 3")
  end
end

describe "have(n).characters where target IS a String" do
  it "passes if the length is correct" do
    "this string".should have(11).characters
  end

  it "fails if the length is incorrect" do
    lambda { "this string".should have(12).characters }.should fail_with("expected 12 characters, got 11")
  end
end

describe "have(n).things on an object which is not a collection nor contains one" do
  it "fails" do
    lambda { Object.new.should have(2).things }.should raise_error(NoMethodError, /undefined method `things' for #<Object:/)
  end
end

describe RSpec::Matchers::Have, "for a collection owner that implements #send" do
  before(:each) do
    @collection = Object.new
    def @collection.floozles; [1,2] end
    def @collection.send(*args); raise "DOH! Library developers shouldn't use #send!" end
  end
  
  it "works in the straightforward case" do
    lambda {
      @collection.should have(2).floozles
    }.should_not raise_error
  end

  it "works when doing automatic pluralization" do
    lambda {
      @collection.should have_at_least(1).floozle
    }.should_not raise_error
  end

  it "blows up when the owner doesn't respond to that method" do
    lambda {
      @collection.should have(99).problems
    }.should raise_error(NoMethodError, /problems/)
  end
end

module RSpec
  module Matchers
    describe Have do
      it "has method_missing as private" do
        with_ruby 1.8 do
          described_class.private_instance_methods.should include("method_missing")
        end
        with_ruby 1.9 do
          described_class.private_instance_methods.should include(:method_missing)
        end
      end

      it "does not respond_to? method_missing (because it's private)" do
        formatter = described_class.new({ }, StringIO.new)
        formatter.should_not respond_to(:method_missing)
      end

      describe "respond_to?" do
        before :each do
          @have = Have.new(:foo)
          @a_method_which_have_defines = Have.instance_methods.first
          @a_method_which_object_defines = Object.instance_methods.first
        end
        
        it "is true for a method which Have defines" do
          @have.should respond_to(@a_method_which_have_defines)
        end
        
        it "is true for a method that it's superclass (Object) defines" do
          @have.should respond_to(@a_method_which_object_defines)
        end
        
        it "is false for a method which neither Object nor nor Have defines" do
          @have.should_not respond_to(:foo_bar_baz)
        end
        
        it "is false if the owner doesn't respond to the method" do
          have = Have.new(99)
          have.should_not respond_to(:problems)
        end
        
        it "is true if the owner responds to the method" do
          have = Have.new(:a_symbol)
          have.should respond_to(:to_sym)
        end
      end
    end
  end
end

end

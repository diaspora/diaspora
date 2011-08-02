require 'spec_helper'
require 'acceptance/acceptance_helper'

require 'factory_girl/syntax/generate'

describe "a factory using generate syntax" do
  before do
    define_model('User', :first_name => :string, :last_name => :string, :email => :string) do
      validates_presence_of :first_name
    end

    FactoryGirl.define do
      factory :user do
        first_name 'Bill'
        last_name  'Nye'
        email      'science@guys.net'
      end
    end
  end

  it "should not raise an error when generating an invalid instance" do
    lambda { User.generate(:first_name => nil) }.should_not raise_error
  end

  it "should raise an error when forcefully generating an invalid instance" do
    lambda { User.generate!(:first_name => nil) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  %w(generate generate! spawn).each do |method|
    it "should yield a generated instance when using #{method} with a block" do
      saved_instance = nil
      User.send(method) {|instance| saved_instance = instance }
      saved_instance.should be_kind_of(User)
    end

    describe "after generating an instance using #{method}" do
      before do
        @instance = User.send(method, :last_name => 'Rye')
      end

      it "should use attributes from the factory" do
        @instance.first_name.should == 'Bill'
      end

      it "should use attributes passed to generate" do
        @instance.last_name.should == 'Rye'
      end

      if method == 'spawn'
        it "should not save the record" do
          @instance.should be_new_record
        end
      else
        it "should save the record" do
          @instance.should_not be_new_record
        end
      end
    end
  end
end

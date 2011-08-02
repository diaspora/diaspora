require 'spec_helper'
require 'acceptance/acceptance_helper'

describe "attribute aliases" do
  before do
    define_model('User')

    define_model('Post', :user_id => :integer) do
      belongs_to :user
    end

    FactoryGirl.define do
      factory :user

      factory :post do
        user
      end
    end
  end

  it "doesn't assign both an association and its foreign key" do
    FactoryGirl.build(:post, :user_id => 1).user_id.should == 1
  end
end


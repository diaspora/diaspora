require 'spec_helper'
require 'acceptance/acceptance_helper'

describe "callbacks" do
  before do
    define_model("User", :first_name => :string, :last_name => :string)

    FactoryGirl.define do
      factory :user_with_callbacks, :class => :user do
        after_stub   { |user| user.first_name = 'Stubby' }
        after_build  { |user| user.first_name = 'Buildy' }
        after_create { |user| user.last_name  = 'Createy' }
      end

      factory :user_with_inherited_callbacks, :parent => :user_with_callbacks do
        after_stub { |user| user.last_name = 'Double-Stubby' }
      end
    end
  end

  it "runs the after_stub callback when stubbing" do
    user = FactoryGirl.build_stubbed(:user_with_callbacks)
    user.first_name.should == 'Stubby'
  end

  it "runs the after_build callback when building" do
    user = FactoryGirl.build(:user_with_callbacks)
    user.first_name.should == 'Buildy'
  end

  it "runs both the after_build and after_create callbacks when creating" do
    user = FactoryGirl.create(:user_with_callbacks)
    user.first_name.should == 'Buildy'
    user.last_name.should == 'Createy'
  end

  it "runs both the after_stub callback on the factory and the inherited after_stub callback" do
    user = FactoryGirl.build_stubbed(:user_with_inherited_callbacks)
    user.first_name.should == 'Stubby'
    user.last_name.should == 'Double-Stubby'
  end
end

require 'spec_helper'
require 'acceptance/acceptance_helper'

describe "a created instance" do
  include FactoryGirl::Syntax::Methods

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

  subject { create('post') }

  it "saves" do
    should_not be_new_record
  end

  it "assigns and saves associations" do
    subject.user.should be_kind_of(User)
    subject.user.should_not be_new_record
  end
end

describe "a custom create" do
  include FactoryGirl::Syntax::Methods

  before do
    define_class('User') do
      def initialize
        @persisted = false
      end

      def persist
        @persisted = true
      end

      def persisted?
        @persisted
      end
    end

    FactoryGirl.define do
      factory :user do
        to_create do |user|
          user.persist
        end
      end
    end
  end

  it "uses the custom create block instead of save" do
    FactoryGirl.create(:user).should be_persisted
  end
end


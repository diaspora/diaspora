require 'spec_helper'

describe TagFollowing do
  before do
    @tag = Factory.create(:tag)
    TagFollowing.create!(:tag => @tag, :user => alice)
  end

  it 'validates uniqueness of tag_following scoped through user' do
    TagFollowing.new(:tag => @tag, :user => alice).valid?.should be_false
  end

  it 'allows multiple tag followings for different users' do
    TagFollowing.new(:tag => @tag, :user => bob).valid?.should be_true
  end
end

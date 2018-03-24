# frozen_string_literal: true

describe TagFollowing, :type => :model do
  before do
    @tag = FactoryGirl.build(:tag)
    TagFollowing.create!(:tag => @tag, :user => alice)
  end

  it 'validates uniqueness of tag_following scoped through user' do
    expect(TagFollowing.new(:tag => @tag, :user => alice).valid?).to be false
  end

  it 'allows multiple tag followings for different users' do
    expect(TagFollowing.new(:tag => @tag, :user => bob).valid?).to be true
  end

  it 'user is following a tag' do
    expect(TagFollowing.user_is_following?(alice, @tag.name)).to be true
  end

  it 'user not following a tag' do
    expect(TagFollowing.user_is_following?(bob, @tag.name)).to be false
  end
  
end

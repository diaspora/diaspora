require 'spec_helper'

describe ConversationVisibility do
  before do
    @user = alice
    @aspect = @user.aspects.create(:name => 'Boozers')

    @person = Factory(:person)
    @post = Factory(:status_message, :author => @person)
  end
  it 'has an aspect' do
    pv = PostVisibility.new(:aspect => @aspect)
    pv.aspect.should == @aspect
  end
  it 'has a post' do
    pv = PostVisibility.new(:post => @post)
    pv.post.should == @post
  end
end

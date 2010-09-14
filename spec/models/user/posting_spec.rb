#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



require File.dirname(__FILE__) + '/../../spec_helper'

describe User do
   before do
     @user = Factory.create :user
     @aspect = @user.aspect(:name => 'heroes')
     @aspect1 = @user.aspect(:name => 'heroes')

     @user2 = Factory.create(:user)
     @aspect2 = @user2.aspect(:name => 'losers') 

     @user3 = Factory.create(:user)
     @aspect3 = @user3.aspect(:name => 'heroes')

     @user4 = Factory.create(:user)
     @aspect4 = @user4.aspect(:name => 'heroes')

     friend_users(@user, @aspect, @user2, @aspect2)
     friend_users(@user, @aspect, @user3, @aspect3)
     friend_users(@user, @aspect1, @user4, @aspect4)
   end

  it 'should not be able to post without a aspect' do
    proc {@user.post(:status_message, :message => "heyheyhey")}.should raise_error /You must post to someone/ 
  end

  it 'should put the post in the aspect post array' do
    post = @user.post(:status_message, :message => "hey", :to => @aspect.id)
    @aspect.reload
    @aspect.post_ids.include?(post.id).should be true
  end

  it 'should put an album in the aspect post array' do
    album = @user.post :album, :name => "Georges", :to => @aspect.id
    @aspect.reload
    @aspect.post_ids.include?(album.id).should be true
    @aspect.posts.include?(album).should be true
  end

  describe 'dispatching' do
    before do
      @post = @user.build_post :status_message, :message => "hey"
    end
    it 'should push a post to a aspect' do
      @user.should_receive(:salmon).twice
      @user.push_to_aspects(@post, @aspect.id)
    end

    it 'should push a post to all aspects' do
      @user.should_receive(:salmon).exactly(3).times
      @user.push_to_aspects(@post, :all)
    end

    it 'should push to people' do
      @user.should_receive(:salmon).twice
      @user.push_to_people(@post, [@user2.person, @user3.person])
    end
    
    
  end
end

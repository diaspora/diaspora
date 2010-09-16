#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require File.dirname(__FILE__) + '/../../spec_helper'

describe User do
   before do
      @user = Factory.create(:user)
      @aspect = @user.aspect(:name => 'heroes')
      @aspect2 = @user.aspect(:name => 'losers')

      @user2 = Factory.create :user
      @user2_aspect = @user2.aspect(:name => 'dudes')

      friend_users(@user, @aspect, @user2, @user2_aspect)

      @user3 = Factory.create :user
      @user3_aspect = @user3.aspect(:name => 'dudes')
      friend_users(@user, @aspect2, @user3, @user3_aspect)
      
      @user4 = Factory.create :user
      @user4_aspect = @user4.aspect(:name => 'dudes')
      friend_users(@user, @aspect2, @user4, @user4_aspect)
   end

    it 'should generate a valid stream for a aspect of people' do
      status_message1 = @user2.post :status_message, :message => "hi", :to => @user2_aspect.id
      status_message2 = @user3.post :status_message, :message => "heyyyy", :to => @user3_aspect.id
      status_message3 = @user4.post :status_message, :message => "yooo", :to => @user4_aspect.id

      @user.receive status_message1.to_diaspora_xml
      @user.receive status_message2.to_diaspora_xml
      @user.receive status_message3.to_diaspora_xml
      @user.reload

      @user.visible_posts(:by_members_of => @aspect).include?(status_message1).should be true
      @user.visible_posts(:by_members_of => @aspect).include?(status_message2).should be false
      @user.visible_posts(:by_members_of => @aspect).include?(status_message3).should be false

      @user.visible_posts(:by_members_of => @aspect2).include?(status_message1).should be false
      @user.visible_posts(:by_members_of => @aspect2).include?(status_message2).should be true
      @user.visible_posts(:by_members_of => @aspect2).include?(status_message3).should be true
    end

    describe 'albums' do
      before do
        @album = @user.post :album, :name => "Georges", :to => @aspect.id
        @aspect.reload
        @aspect2.reload
        @user.reload

        @album2 = @user.post :album, :name => "Borges", :to => @aspect.id
        @aspect.reload
        @aspect2.reload
        @user.reload

        @user.post :album, :name => "Luises", :to => @aspect2.id
        @aspect.reload
        @aspect2.reload
        @user.reload
      end

      it 'should find all albums if passed :all' do
        @user.albums_by_aspect(:all).size.should == 3
      end

      it 'should return the right number of albums' do
        @user.albums_by_aspect(@aspect).size.should == 2
        @user.albums_by_aspect(@aspect2).size.should == 1
      end
    end
end


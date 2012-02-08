#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe NotificationsController do
  render_views(false)
  before do
    @user = alice
    @aspect = @user.aspects.first
    @controller = NotificationsController.new
    @controller.stub!(:current_user).and_return(@user)
  end

  describe '#update' do
    it 'marks a notification as read if it gets no other information' do
      note = mock_model( Notification )
      Notification.should_receive( :where ).and_return( [note] )
      note.should_receive( :set_read_state ).with( true )
      get :update, "id" => note.id
    end
    it 'marks a notification as read if it is told to' do
      note = mock_model( Notification )
      Notification.should_receive( :where ).and_return( [note] )
      note.should_receive( :set_read_state ).with( true )
      get :update, "id" => note.id, :set_unread => "false"
    end

    it 'marks a notification as unread if it is told to' do
      note = mock_model( Notification )
      Notification.should_receive( :where ).and_return( [note] )
      note.should_receive( :set_read_state ).with( false )
      get :update, "id" => note.id, :set_unread => "true"
    end

    it 'only lets you read your own notifications' do
      user2 = bob

      Factory(:notification, :recipient => @user)
      note = Factory(:notification, :recipient => user2)

      get :update, "id" => note.id, :set_unread => "false"

      Notification.find(note.id).unread.should == true
    end
  end

  describe "#read_all" do
    it 'marks all notifications as read' do
      request.env["HTTP_REFERER"] = "I wish I were spelled right"
      Factory(:notification, :recipient => @user)
      Factory(:notification, :recipient => @user)

      Notification.where(:unread => true).count.should == 2
      get :read_all
      Notification.where(:unread => true).count.should == 0
    end
    it "should redirect to the stream in the html version" do
      Factory(:notification, :recipient => @user)
      get :read_all, :format => :html
      response.should redirect_to(explore_path)
    end
    it "should return a dummy value in the json version" do
      Factory(:notification, :recipient => @user)
      get :read_all, :format => :json
      response.should_not be_redirect
    end
  end

  describe '#index' do
    before do
      @post = Factory(:status_message)
      Factory(:notification, :recipient => @user, :target => @post)
    end

    it 'paginates the notifications' do
      25.times { Factory(:notification, :recipient => @user, :target => @post) }
      get :index
      assigns[:notifications].count.should == 25
      get :index, "page" => 2
      assigns[:notifications].count.should == 1
    end

    it "supports a limit per_page parameter" do
      5.times { Factory(:notification, :recipient => @user, :target => @post) }
      get :index, "per_page" => 5
      assigns[:notifications].count.should == 5 
    end

    describe "special case for start sharing notifications" do
      it "should not provide a contacts menu for standard notifications" do
        2.times { Factory(:notification, :recipient => @user, :target => @post) }
        get :index, "per_page" => 5

        Nokogiri(response.body).css('.aspect_membership').should be_empty
      end
      it "should provide a contacts menu for start sharing notifications" do
        2.times { Factory(:notification, :recipient => @user, :target => @post) }
        eve.share_with(alice.person, eve.aspects.first)
        get :index, "per_page" => 5

        Nokogiri(response.body).css('.aspect_membership').should_not be_empty
      end


      
    end
  end
end

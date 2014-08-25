#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe NotificationsController, :type => :controller do
  before do
    sign_in :user, alice
  end

  describe '#update' do
    it 'marks a notification as read if it gets no other information' do
      note = FactoryGirl.create(:notification)
      expect(Notification).to receive( :where ).and_return( [note] )
      expect(note).to receive( :set_read_state ).with( true )
      get :update, "id" => note.id, :format => :json
    end

    it 'marks a notification as read if it is told to' do
      note = FactoryGirl.create(:notification)
      expect(Notification).to receive( :where ).and_return( [note] )
      expect(note).to receive( :set_read_state ).with( true )
      get :update, "id" => note.id, :set_unread => "false", :format => :json
    end

    it 'marks a notification as unread if it is told to' do
      note = FactoryGirl.create(:notification)
      expect(Notification).to receive( :where ).and_return( [note] )
      expect(note).to receive( :set_read_state ).with( false )
      get :update, "id" => note.id, :set_unread => "true", :format => :json
    end

    it 'only lets you read your own notifications' do
      user2 = bob

      FactoryGirl.create(:notification, :recipient => alice)
      note = FactoryGirl.create(:notification, :recipient => user2)

      get :update, "id" => note.id, :set_unread => "false", :format => :json

      expect(Notification.find(note.id).unread).to eq(true)
    end
  end

  describe '#index' do
    before do
      @post = FactoryGirl.create(:status_message)
      FactoryGirl.create(:notification, :recipient => alice, :target => @post)
    end

    it 'succeeds' do
      get :index
      expect(response).to be_success
      expect(assigns[:notifications].count).to eq(1)
    end

    it 'succeeds for notification dropdown' do
      get :index, :format => :json
      expect(response).to be_success
      expect(response.body).to match(/note_html/)
    end

    it 'succeeds on mobile' do
      get :index, :format => :mobile
      expect(response).to be_success
    end

    it 'paginates the notifications' do
      25.times { FactoryGirl.create(:notification, :recipient => alice, :target => @post) }
      get :index
      expect(assigns[:notifications].count).to eq(25)
      get :index, "page" => 2
      expect(assigns[:notifications].count).to eq(1)
    end

    it "supports a limit per_page parameter" do
      5.times { FactoryGirl.create(:notification, :recipient => alice, :target => @post) }
      get :index, "per_page" => 5
      expect(assigns[:notifications].count).to eq(5)
    end

    describe "special case for start sharing notifications" do
      it "should not provide a contacts menu for standard notifications" do
        2.times { FactoryGirl.create(:notification, :recipient => alice, :target => @post) }
        get :index, "per_page" => 5

        expect(Nokogiri(response.body).css('.aspect_membership')).to be_empty
      end
      it "should provide a contacts menu for start sharing notifications" do
        2.times { FactoryGirl.create(:notification, :recipient => alice, :target => @post) }
        eve.share_with(alice.person, eve.aspects.first)
        get :index, "per_page" => 5

        expect(Nokogiri(response.body).css('.aspect_membership')).not_to be_empty
      end
    end

    describe "filter notifications" do
      it "supports filtering by notification type" do
        eve.share_with(alice.person, eve.aspects.first)
        get :index, "type" => "started_sharing"
        expect(assigns[:notifications].count).to eq(1)
      end

      it "supports filtering by read/unread" do
        get :read_all
        2.times { FactoryGirl.create(:notification, :recipient => alice, :target => @post) }
        get :index, "show" => "unread"
        expect(assigns[:notifications].count).to eq(2)
      end
    end
  end

  describe "#read_all" do
    it 'marks all notifications as read' do
      request.env["HTTP_REFERER"] = "I wish I were spelled right"
      FactoryGirl.create(:notification, :recipient => alice)
      FactoryGirl.create(:notification, :recipient => alice)

      expect(Notification.where(:unread => true).count).to eq(2)
      get :read_all
      expect(Notification.where(:unread => true).count).to eq(0)
    end
    it 'marks all notifications in the current filter as read' do
      request.env["HTTP_REFERER"] = "I wish I were spelled right"
      FactoryGirl.create(:notification, :recipient => alice)
      eve.share_with(alice.person, eve.aspects.first)
      expect(Notification.where(:unread => true).count).to eq(2)
      get :read_all, "type" => "started_sharing"
      expect(Notification.where(:unread => true).count).to eq(1)
    end
    it "should redirect back in the html version if it has > 0 notifications" do
      FactoryGirl.create(:notification, :recipient => alice)
      eve.share_with(alice.person, eve.aspects.first)
      get :read_all, :format => :html, "type" => "started_sharing"
      expect(response).to redirect_to(notifications_path)
    end
    it "should redirect back in the mobile version if it has > 0 notifications" do
      FactoryGirl.create(:notification, :recipient => alice)
      eve.share_with(alice.person, eve.aspects.first)
      get :read_all, :format => :mobile, "type" => "started_sharing"
      expect(response).to redirect_to(notifications_path)
    end
    it "should redirect to stream in the html version if it has 0 notifications" do
      FactoryGirl.create(:notification, :recipient => alice)
      get :read_all, :format => :html
      expect(response).to redirect_to(stream_path)
    end
    it "should redirect back in the mobile version if it has 0 notifications" do
      FactoryGirl.create(:notification, :recipient => alice)
      get :read_all, :format => :mobile
      expect(response).to redirect_to(stream_path)
    end
    it "should return a dummy value in the json version" do
      FactoryGirl.create(:notification, :recipient => alice)
      get :read_all, :format => :json
      expect(response).not_to be_redirect
    end
  end
end

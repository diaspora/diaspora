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
    it 'marks a notification as read' do
      note = Factory(:notification, :recipient => @user)
      @controller.update :id => note.id
      Notification.first.unread.should == false
    end

    it 'only lets you read your own notifications' do
      user2 = bob

      Factory(:notification, :recipient => @user)
      note = Factory(:notification, :recipient => user2)

      @controller.update :id => note.id

      Notification.find(note.id).unread.should == true
    end
  end

  describe "#read_all" do
    it 'marks all notifications as read' do
      request.env["HTTP_REFERER"] = "I wish I were spelled right"
      Factory(:notification, :recipient => @user)
      Factory(:notification, :recipient => @user)

      Notification.where(:unread => true).count.should == 2
      @controller.read_all({})
      Notification.where(:unread => true).count.should == 0
    end
  end

  describe '#index' do
    before do
      @post = Factory(:status_message)
      Factory(:notification, :recipient => @user, :target => @post)
    end

    it 'paginates the notifications' do
      25.times { Factory(:notification, :recipient => @user, :target => @post) }

      @controller.index({})[:notifications].count.should == 25
      @controller.index(:page => 2)[:notifications].count.should == 1
    end

    it "includes the actors" do
      Factory(:notification, :recipient => @user, :target => @post)
      response = @controller.index({})
      response[:notifications].first[:actors].first.should be_a(Person)
    end

    it 'eager loads the target' do
      response = @controller.index({})
      response[:notifications].each { |note| note[:target].should be }
    end

    it "supports a limit per_page parameter" do
      5.times { Factory(:notification, :recipient => @user, :target => @post) }
      response = @controller.index({:per_page => 5})
      response[:notifications].length.should == 5
    end
  end
end

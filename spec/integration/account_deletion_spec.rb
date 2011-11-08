require 'spec_helper'

describe 'deleteing your account' do
  before :all do
    @bob2 = bob
    @bobs_person_id = @bob2.person.id
    @alices_post = alice.post(:status_message, :text => "@{@bob2 Grimn; #{@bob2.person.diaspora_handle}} you are silly", :to => alice.aspects.find_by_name('generic'))

    @bobs_contact_ids = @bob2.contacts.map {|c| c.id}

    #@bob2's own content
    @bob2.post(:status_message, :text => 'asldkfjs', :to => @bob2.aspects.first)
    f = Factory(:photo, :author => @bob2.person)

    #objects on post
    @bob2.like(true, :target => @alices_post)
    @bob2.comment("here are some thoughts on your post", :post => @alices_post)

    #conversations
    create_conversation_with_message(alice, @bob2, "Subject", "Hey @bob2")

    #join tables
    @users_sv = ShareVisibility.where(:contact_id => @bobs_contact_ids).all
    @persons_sv = ShareVisibility.where(:contact_id => bob.person.contacts.map(&:id)).all

    #user associated objects
    @prefs = []
    %w{mentioned liked reshared}.each do |pref|
      @prefs << @bob2.user_preferences.create!(:email_type => pref)
    end

    # notifications
    @notifications = []
    3.times do |n|
      @notifications << Factory(:notification, :recipient => @bob2)
    end

    # services
    @services = []
    3.times do |n|
      @services << Factory(:service, :user => @bob2)
    end

    # block
    @block = @bob2.blocks.create!(:person => eve.person)

    AccountDeletion.new(@bob2.person.diaspora_handle).perform!
    @bob2.reload
  end

  it 'deletes all of @bob2s posts' do
    @bob2.posts.should be_empty
  end

  it "deletes all of the user's preferences" do
    UserPreference.where(:id => @prefs.map{|pref| pref.id}).should be_empty
  end

  it "deletes all of the user's notifications" do
    Notification.where(:id => @notifications.map{|n| n.id}).should be_empty
  end

  it "deletes all of the users's blocked users" do
    Block.where(:id => @block.id).should be_empty
  end

  it "deletes all of the user's services" do
    Service.where(:id => @services.map{|s| s.id}).should be_empty
  end

  it 'deletes all of @bob2s share visiblites' do
    ShareVisibility.where(:id => @users_sv.map{|sv| sv.id}).should be_empty
    ShareVisibility.where(:id => @persons_sv.map{|sv| sv.id}).should be_empty
  end

  it 'deletes all photos' do
    Photo.where(:author_id => @bobs_person_id).should be_empty
  end

  it 'deletes all mentions' do
    @bob2.person.mentions.should be_empty
  end

  it 'deletes all aspects' do
    @bob2.aspects.should be_empty
  end

  it 'deletes all contacts' do
    @bob2.contacts.should be_empty
  end

  it 'sets the person object as closed and the profile is cleared' do
    @bob2.person.reload.closed_account.should  be_true

    @bob2.person.profile.reload.first_name.should  be_blank
  end

  it 'deletes only the converersation visibility for the deleted user' do
    ConversationVisibility.where(:person_id => alice.person.id).should_not be_empty
    ConversationVisibility.where(:person_id => bob.person.id).should be_empty
  end
end

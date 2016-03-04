require 'spec_helper'

describe 'deleteing your account', :type => :request do
  context "user" do
    before do
      @bob2 = bob
      @person = @bob2.person
      @alices_post = alice.post(:status_message, :text => "@{@bob2 Grimn; #{@bob2.person.diaspora_handle}} you are silly", :to => alice.aspects.find_by_name('generic'))

      @bobs_contact_ids = @bob2.contacts.map {|c| c.id}

      #@bob2's own content
      @bob2.post(:status_message, :text => 'asldkfjs', :to => @bob2.aspects.first)
      f = FactoryGirl.create(:photo, :author => @bob2.person)

      @aspect_vis = AspectVisibility.where(:aspect_id => @bob2.aspects.map(&:id))

      #objects on post
      @bob2.like!(@alices_post)
      @bob2.comment!(@alices_post, "here are some thoughts on your post")

      #conversations
      create_conversation_with_message(alice, @bob2.person, "Subject", "Hey @bob2")

      #join tables
      @users_sv = ShareVisibility.where(:contact_id => @bobs_contact_ids).load
      @persons_sv = ShareVisibility.where(:contact_id => bob.person.contacts.map(&:id)).load

      #user associated objects
      @prefs = []
      %w{mentioned liked reshared}.each do |pref|
        @prefs << @bob2.user_preferences.create!(:email_type => pref)
      end

      # notifications
      @notifications = []
      3.times do |n|
        @notifications << FactoryGirl.create(:notification, :recipient => @bob2)
      end

      # services
      @services = []
      3.times do |n|
        @services << FactoryGirl.create(:service, :user => @bob2)
      end

      # block
      @block = @bob2.blocks.create!(:person => eve.person)

      #authorization

      AccountDeleter.new(@bob2.person.diaspora_handle).perform!
      @bob2.reload
    end

    it "deletes all of the user's preferences" do
      expect(UserPreference.where(:id => @prefs.map{|pref| pref.id})).to be_empty
    end

    it "deletes all of the user's notifications" do
      expect(Notification.where(:id => @notifications.map{|n| n.id})).to be_empty
    end

    it "deletes all of the users's blocked users" do
      expect(Block.where(:id => @block.id)).to be_empty
    end

    it "deletes all of the user's services" do
      expect(Service.where(:id => @services.map{|s| s.id})).to be_empty
    end

    it 'deletes all of @bob2s share visiblites' do
      expect(ShareVisibility.where(:id => @users_sv.map{|sv| sv.id})).to be_empty
      expect(ShareVisibility.where(:id => @persons_sv.map{|sv| sv.id})).to be_empty
    end

    it 'deletes all of @bob2s aspect visiblites' do
      expect(AspectVisibility.where(:id => @aspect_vis.map(&:id))).to be_empty
    end

    it 'deletes all aspects' do
      expect(@bob2.aspects).to be_empty
    end

    it 'deletes all user contacts' do
      expect(@bob2.contacts).to be_empty
    end


    it "clears the account fields" do
      @bob2.send(:clearable_fields).each do |field|
        expect(@bob2.reload[field]).to be_blank
      end
    end

    it_should_behave_like 'it removes the person associations'
  end

  context 'remote person' do
    before do
      @person = remote_raphael

      #contacts
      @contacts = @person.contacts

      #posts
      @posts = (1..3).map do
        FactoryGirl.create(:status_message, :author => @person)
      end

      @persons_sv = @posts.each do |post|
        @contacts.each do |contact|
          ShareVisibility.create!(:contact_id => contact.id, :shareable => post)
        end
      end

      #photos
      @photo = FactoryGirl.create(:photo, :author => @person)

      #mentions
      @mentions = 3.times do
        FactoryGirl.create(:mention, :person => @person)
      end

      #conversations
      create_conversation_with_message(alice, @person, "Subject", "Hey @bob2")

      AccountDeleter.new(@person.diaspora_handle).perform!
      @person.reload
    end

      it_should_behave_like 'it removes the person associations'
  end
end

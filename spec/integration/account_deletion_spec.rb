describe "deleteing your account", type: :request do
  context "user" do
    before do
      @person = bob.person
      @alices_post = alice.post(:status_message,
                                text: "@{bob Grimn; #{bob.person.diaspora_handle}} you are silly",
                                to:   alice.aspects.find_by_name("generic"))

      # bob's own content
      bob.post(:status_message, text: "asldkfjs", to: bob.aspects.first)
      FactoryGirl.create(:photo, author: bob.person)

      @aspect_vis = AspectVisibility.where(aspect_id: bob.aspects.map(&:id))

      # objects on post
      bob.like!(@alices_post)
      bob.comment!(@alices_post, "here are some thoughts on your post")

      # conversations
      create_conversation_with_message(alice, bob.person, "Subject", "Hey bob")

      # join tables
      @users_sv = ShareVisibility.where(user_id: bob.id).load
      @persons_sv = ShareVisibility.where(shareable_id: bob.posts.map(&:id), shareable_type: "Post").load

      # user associated objects
      @prefs = []
      %w(mentioned liked reshared).each do |pref|
        @prefs << bob.user_preferences.create!(email_type: pref)
      end

      # notifications
      @notifications = []
      3.times do
        @notifications << FactoryGirl.create(:notification, recipient: bob)
      end

      # services
      @services = []
      3.times do
        @services << FactoryGirl.create(:service, user: bob)
      end

      # block
      @block = bob.blocks.create!(person: eve.person)

      AccountDeleter.new(bob.person.diaspora_handle).perform!
      bob.reload
    end

    it "deletes all of the user's preferences" do
      expect(UserPreference.where(id: @prefs.map(&:id))).to be_empty
    end

    it "deletes all of the user's notifications" do
      expect(Notification.where(id: @notifications.map(&:id))).to be_empty
    end

    it "deletes all of the users's blocked users" do
      expect(Block.where(id: @block.id)).to be_empty
    end

    it "deletes all of the user's services" do
      expect(Service.where(id: @services.map(&:id))).to be_empty
    end

    it "deletes all of bobs share visiblites" do
      expect(ShareVisibility.where(id: @users_sv.map(&:id))).to be_empty
      expect(ShareVisibility.where(id: @persons_sv.map(&:id))).to be_empty
    end

    it "deletes all of bobs aspect visiblites" do
      expect(AspectVisibility.where(id: @aspect_vis.map(&:id))).to be_empty
    end

    it "deletes all aspects" do
      expect(bob.aspects).to be_empty
    end

    it "deletes all user contacts" do
      expect(bob.contacts).to be_empty
    end

    it "clears the account fields" do
      bob.send(:clearable_fields).each do |field|
        expect(bob.reload[field]).to be_blank
      end
    end

    it_should_behave_like "it removes the person associations"
  end

  context "remote person" do
    before do
      @person = remote_raphael

      # contacts
      @contacts = @person.contacts

      # posts
      @posts = (1..3).map do
        FactoryGirl.create(:status_message, author: @person)
      end

      @persons_sv = @posts.each do |post|
        @contacts.each do |contact|
          ShareVisibility.create!(user_id: contact.user.id, shareable: post)
        end
      end

      # photos
      @photo = FactoryGirl.create(:photo, author: @person)

      # mentions
      @mentions = 3.times do
        FactoryGirl.create(:mention, person: @person)
      end

      # conversations
      create_conversation_with_message(alice, @person, "Subject", "Hey bob")

      AccountDeleter.new(@person.diaspora_handle).perform!
      @person.reload
    end

    it_should_behave_like "it removes the person associations"
  end
end

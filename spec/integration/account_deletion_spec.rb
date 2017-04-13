describe "deleteing account", type: :request do
  def account_removal_method
    AccountDeleter.new(subject.diaspora_handle).perform!
    subject.reload
  end

  context "of local user" do
    subject(:user) { FactoryGirl.create(:user_with_aspect) }

    before do
      DataGenerator.create(subject, :generic_user_data)
    end

    it "deletes all of the user data" do
      expect {
        account_removal_method
      }.to change(nil, "user preferences empty?") { UserPreference.where(user_id: user.id).empty? }.to(be_truthy)
        .and(change(nil, "notifications empty?") { Notification.where(recipient_id: user.id).empty? }.to(be_truthy))
        .and(change(nil, "blocks empty?") { Block.where(user_id: user.id).empty? }.to(be_truthy))
        .and(change(nil, "services empty?") { Service.where(user_id: user.id).empty? }.to(be_truthy))
        .and(change(nil, "share visibilities empty?") { ShareVisibility.where(user_id: user.id).empty? }.to(be_truthy))
        .and(change(nil, "aspects empty?") { user.aspects.empty? }.to(be_truthy))
        .and(change(nil, "contacts empty?") { user.contacts.empty? }.to(be_truthy))
        .and(change(nil, "tag followings empty?") { user.tag_followings.empty? }.to(be_truthy))
        .and(change(nil, "clearable fields blank?") {
          user.send(:clearable_fields).map {|field|
            user.reload[field].blank?
          }
        }.to(eq([true] * user.send(:clearable_fields).count)))
    end

    it_behaves_like "it removes the person associations" do
      subject(:person) { user.person }
    end
  end

  context "of remote person" do
    subject(:person) { remote_raphael }

    before do
      DataGenerator.create(subject, :generic_person_data)
    end

    it_behaves_like "it removes the person associations"
  end
end

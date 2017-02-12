module MentioningSpecHelpers
  def default_aspect
    @user1.aspects.where(name: "generic").first
  end

  def text_mentioning(user)
    "this is a text mentioning @{#{user.name}; #{user.diaspora_handle}} ... have fun testing!"
  end

  def stream_for(user)
    stream = Stream::Multi.new(user)
    stream.posts
  end

  def mention_stream_for(user)
    stream = Stream::Mention.new(user)
    stream.posts
  end

  def users_connected?(user1, user2)
    user1.contacts.where(person_id: user2.person).count > 0
  end
end


describe "mentioning", type: :request do
  include MentioningSpecHelpers

  before do
    @user1 = FactoryGirl.create :user_with_aspect
    @user2 = FactoryGirl.create :user
    @user3 = FactoryGirl.create :user

    @user1.share_with(@user2.person, default_aspect)
    sign_in @user1
  end

  # see: https://github.com/diaspora/diaspora/issues/4160
  it "doesn't mention people that aren't in the target aspect" do
    expect(users_connected?(@user1, @user3)).to be false

    status_msg = nil
    expect {
      post "/status_messages.json", status_message: {text: text_mentioning(@user3)}, aspect_ids: default_aspect.id.to_s
      status_msg = StatusMessage.find(JSON.parse(response.body)["id"])
    }.to change(Post, :count).by(1).and change(AspectVisibility, :count).by(1)

    expect(status_msg).not_to be_nil
    expect(status_msg.public?).to be false
    expect(status_msg.text).to include(@user3.name)
    expect(status_msg.text).not_to include(@user3.diaspora_handle)
    expect(status_msg.text).to include(user_profile_path(username: @user3.username))

    expect(stream_for(@user3).map(&:id)).not_to include(status_msg.id)
    expect(mention_stream_for(@user3).map(&:id)).not_to include(status_msg.id)
  end

  it "mentions people in public posts" do
    expect(users_connected?(@user1, @user3)).to be false

    status_msg = nil
    expect {
      post "/status_messages.json", status_message: {text: text_mentioning(@user3)}, aspect_ids: "public"
      status_msg = StatusMessage.find(JSON.parse(response.body)["id"])
    }.to change(Post, :count).by(1)

    expect(status_msg).not_to be_nil
    expect(status_msg.public?).to be true
    expect(status_msg.text).to include(@user3.name)
    expect(status_msg.text).to include(@user3.diaspora_handle)

    expect(stream_for(@user3).map(&:id)).to include(status_msg.id)
    expect(mention_stream_for(@user3).map(&:id)).to include(status_msg.id)
  end

  it "mentions people that are in the target aspect" do
    expect(users_connected?(@user1, @user2)).to be true

    status_msg = nil
    expect {
      post "/status_messages.json", status_message: {text: text_mentioning(@user2)}, aspect_ids: default_aspect.id.to_s
      status_msg = StatusMessage.find(JSON.parse(response.body)["id"])
    }.to change(Post, :count).by(1).and change(AspectVisibility, :count).by(1)

    expect(status_msg).not_to be_nil
    expect(status_msg.public?).to be false
    expect(status_msg.text).to include(@user2.name)
    expect(status_msg.text).to include(@user2.diaspora_handle)

    expect(stream_for(@user2).map(&:id)).to include(status_msg.id)
    expect(mention_stream_for(@user2).map(&:id)).to include(status_msg.id)
  end
end

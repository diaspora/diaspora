# frozen_string_literal: true

describe NotificationPresenter do
  before do
    @post = FactoryGirl.create(:status_message)
    @notification = FactoryGirl.create(:notification, recipient: alice, target: @post)
  end

  it "makes json with target when requested" do
    json = NotificationPresenter.new(@notification).as_api_json(true)
    expect(json[:guid]).to eq(@notification.guid)
    expect(json[:type]).to eq("also_commented")
    expect(json[:read]).to be_falsey
    expect(json[:created_at]).to eq(@notification.created_at)
    expect(json[:target][:guid]).to eq(@post.guid)
    expect(json[:event_creators].length).to eq(1)
  end

  it "makes json with without target" do
    json = NotificationPresenter.new(@notification).as_api_json(false)
    expect(json.has_key?(:target)).to be_falsey
  end
end

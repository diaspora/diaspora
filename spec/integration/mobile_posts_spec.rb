require "spec_helper"

describe PostsController, type: :request do
  context "with a poll" do
    let(:sm) { FactoryGirl.build(:status_message_with_poll, public: true) }

    it "displays the poll" do
      get "/posts/#{sm.id}", format: :mobile

      expect(response.status).to eq(200)
      expect(response.body).to match(/div class='poll'/)
      expect(response.body).to match(/#{sm.poll.poll_answers.first.answer}/)
    end
  end

  context "with a location" do
    let(:sm) { FactoryGirl.build(:status_message_with_location, public: true) }

    it "displays the location" do
      get "/posts/#{sm.id}", format: :mobile

      expect(response.status).to eq(200)
      expect(response.body).to match(/div class='location'/)
      expect(response.body).to match(/#{I18n.t("posts.show.location", location: sm.location.address)}/)
    end
  end
end

# frozen_string_literal: true

describe PostsController, type: :request do
  context "with a poll" do
    let(:sm) { FactoryGirl.build(:status_message_with_poll, public: true) }

    it "displays the poll" do
      get "/posts/#{sm.id}", params: {format: :mobile}

      expect(response.status).to eq(200)
      expect(response.body).to match(/div class='poll'/)
      expect(response.body).to match(/#{sm.poll.poll_answers.first.answer}/)
    end

    it "displays the correct percentage for the answers" do
      alice.participate_in_poll!(sm, sm.poll.poll_answers.first)
      bob.participate_in_poll!(sm, sm.poll.poll_answers.last)
      get "/posts/#{sm.id}", params: {format: :mobile}

      expect(response.status).to eq(200)
      expect(response.body).to match(/div class='percentage pull-right'>\n50%/)
    end
  end

  context "with a location" do
    let(:sm) { FactoryGirl.build(:status_message_with_location, public: true) }

    it "displays the location" do
      get "/posts/#{sm.id}", params: {format: :mobile}

      expect(response.status).to eq(200)
      expect(response.body).to match(/'location nsfw-hidden'/)
      expect(response.body).to match(/#{I18n.t("posts.show.location", location: sm.location.address)}/)
    end
  end
end

# frozen_string_literal: true

describe PeopleController, type: :request do
  context "for the current user" do
    before do
      sign_in alice
    end

    it "displays the publisher for user profile path" do
      get "/u/#{alice.username}"

      expect(response.status).to eq(200)
      # make sure we are signed in
      expect(response.body).not_to match(/a class="login"/)
      expect(response.body).to match(/div class='publisher-textarea-wrapper' id='publisher-textarea-wrapper'/)
    end

    it "displays the publisher for people path" do
      get "/people/#{alice.person.guid}"

      expect(response.status).to eq(200)
      # make sure we are signed in
      expect(response.body).not_to match(/a class="login"/)
      expect(response.body).to match(/div class='publisher-textarea-wrapper' id='publisher-textarea-wrapper'/)
    end

    it "doesn't display the publisher for people photos path" do
      get "/people/#{alice.person.guid}/photos"

      expect(response.status).to eq(200)
      # make sure we are signed in
      expect(response.body).not_to match(/a class="login"/)
      expect(response.body).not_to match(/div class='publisher-textarea-wrapper' id='publisher-textarea-wrapper'/)
    end
  end

  context "for another user" do
    before do
      sign_in bob
    end

    it "doesn't display the publisher for user profile path" do
      get "/u/#{alice.username}"

      expect(response.status).to eq(200)
      # make sure we are signed in
      expect(response.body).not_to match(/a class="login"/)
      expect(response.body).not_to match(/div class='publisher-textarea-wrapper' id='publisher-textarea-wrapper'/)
    end

    it "doesn't display the publisher for people path" do
      get "/people/#{alice.person.guid}"

      expect(response.status).to eq(200)
      # make sure we are signed in
      expect(response.body).not_to match(/a class="login"/)
      expect(response.body).not_to match(/div class='publisher-textarea-wrapper' id='publisher-textarea-wrapper'/)
    end
  end

  context "with no user signed in" do
    it "doesn't display the publisher for user profile path" do
      get "/u/#{alice.username}"

      expect(response.status).to eq(200)
      # make sure we aren't signed in
      expect(response.body).to match(/a class="login"/)
      expect(response.body).not_to match(/div class='publisher-textarea-wrapper' id='publisher-textarea-wrapper'/)
    end

    it "doesn't display the publisher for people path" do
      get "/people/#{alice.person.guid}"

      expect(response.status).to eq(200)
      # make sure we aren't signed in
      expect(response.body).to match(/a class="login"/)
      expect(response.body).not_to match(/div class='publisher-textarea-wrapper' id='publisher-textarea-wrapper'/)
    end
  end
end

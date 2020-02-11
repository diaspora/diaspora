# frozen_string_literal: true

describe HelpController, type: :controller do
  describe "#faq" do
    it "succeeds" do
      get :faq
      expect(response).to be_successful
    end

    it "fails on mobile" do
      expect {
        get :faq, format: :mobile
      }.to raise_error ActionController::UnknownFormat
    end
  end
end

# frozen_string_literal: true

describe HelpController, type: :controller do
  describe "#faq" do
    it "succeeds" do
      get :faq
      expect(response).to be_successful
    end

    it "succeeds on mobile" do
      get :faq, format: :mobile
      expect(response).to be_successful
    end
  end
end

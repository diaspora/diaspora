describe HelpController, type: :controller do
  describe "#faq" do
    it "succeeds" do
      get :faq
      expect(response).to be_success
    end

    it "fails on mobile" do
      expect {
        get :faq, format: :mobile
      }.to raise_error ActionView::MissingTemplate
    end
  end
end

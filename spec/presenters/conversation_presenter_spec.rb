# frozen_string_literal: true

describe ConversationPresenter do
  before do
    @conversation = FactoryBot.create(:conversation)
    @presenter = ConversationPresenter.new(@conversation)
  end

  describe "#as_json" do
    it "works" do
      expect(@presenter.as_json).to be_a Hash
    end
  end
end

# frozen_string_literal: true

describe AspectPresenter do
  before do
    @aspect = bob.aspects.first
    @presenter = AspectPresenter.new(@aspect)
  end

  describe '#to_json' do
    it 'works' do
      expect(@presenter.to_json).to be_present
    end
  end

  describe "#to_api_json" do
    it "creates simple JSON" do
      aspect_json = @presenter.as_api_json(false)
      expect(aspect_json[:id]).to eq(@aspect.id)
      expect(aspect_json[:name]).to eq(@aspect.name)
      expect(aspect_json[:order]).to eq(@aspect.order_id)
    end

    it "produces full JSON" do
      aspect_json = @presenter.as_api_json(true)
      expect(aspect_json[:id]).to eq(@aspect.id)
      expect(aspect_json[:name]).to eq(@aspect.name)
      expect(aspect_json[:order]).to eq(@aspect.order_id)
    end
  end
end

# frozen_string_literal: true

describe AspectPresenter do
  before do
    @presenter = AspectPresenter.new(bob.aspects.first)
  end

  describe '#to_json' do
    it 'works' do
      expect(@presenter.to_json).to be_present
    end
  end
end
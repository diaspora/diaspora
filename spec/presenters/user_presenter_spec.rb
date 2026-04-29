# frozen_string_literal: true

describe UserPresenter do
  before do
    @presenter = UserPresenter.new(bob, [])
  end

  describe '#to_json' do
    it 'works' do
      expect(@presenter.to_json).to be_present
    end
  end

  describe '#aspects' do
    it 'provides an array of the jsonified aspects' do
      aspect = bob.aspects.first
      expect(@presenter.aspects.first[:id]).to eq(aspect.id)
      expect(@presenter.aspects.first[:name]).to eq(aspect.name)
    end
  end

end

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

  describe '#services' do
    it 'provides an array of jsonifed services' do
      fakebook = double(:provider => 'fakebook')
      allow(bob).to receive(:services).and_return([fakebook])
      expect(@presenter.services).to include(:provider => 'fakebook')
    end
  end

  describe '#configured_services' do
    it 'displays a list of the users configured services' do
      fakebook = double(:provider => 'fakebook')
      allow(bob).to receive(:services).and_return([fakebook])
      expect(@presenter.configured_services).to include("fakebook")
    end
  end
end

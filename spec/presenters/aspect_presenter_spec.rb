require 'spec_helper'

describe AspectPresenter do
  before do
    @presenter = AspectPresenter.new(bob.aspects.first)
  end

  describe '#to_json' do
    it 'works' do
      @presenter.to_json.should be_present
    end
  end
end
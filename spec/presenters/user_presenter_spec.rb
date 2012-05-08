require 'spec_helper'

describe UserPresenter do
  before do
    @presenter = UserPresenter.new(bob)
  end

  describe '#to_json' do
    it 'works' do
      @presenter.to_json.should be_present
    end
  end

  describe '#aspects' do
    it 'provides an array of the jsonified aspects' do
      aspect = bob.aspects.first
      @presenter.aspects.first[:id].should == aspect.id
      @presenter.aspects.first[:name].should == aspect.name
    end
  end

  describe '#services' do
    it 'provides an array of jsonifed services' do
      fakebook = stub(:provider => 'fakebook')
      bob.stub(:services).and_return([fakebook])
      @presenter.services.should include(:provider => 'fakebook')
    end
  end
end
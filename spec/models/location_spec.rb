require 'spec_helper'

describe Location do
  before(:each) do
    WebMock.allow_net_connect!
  end

  describe 'valid location data' do
    describe 'based on address' do
      before(:each) do
        @location = Location.create!(:address => "Boston, Massachusetts, USA")
      end

      it 'should include longitude and latitude' do
        @location.longitude.should_not be_nil
        @location.latitude.should_not be_nil
      end

      it 'should include an address' do
        @location.address.should_not be_nil
      end
    end

    describe 'based on longitude/latitude' do
      before(:each) do
        @location = Location.create!(:latitude => 40.71, :longitude => -74.0)
      end

      it 'should include longitude and latitude' do
        @location.longitude.should_not be_nil
        @location.latitude.should_not be_nil
      end

      it 'should include address' do
        @location.address.should_not be_nil
      end
    end
  end
end

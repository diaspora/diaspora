require 'spec_helper'

describe Location, :type => :model do
  describe 'before validation' do
    it 'should create new location when it has coordinates' do
      location = Location.new(coordinates:'1,2')
      expect(location.save).to be true
    end

    it 'should not create new location when it does not have coordinates' do
      location = Location.new()
      expect(location.save).to be false
    end
  end
end

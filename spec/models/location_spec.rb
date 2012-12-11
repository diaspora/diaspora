require 'spec_helper'

describe Location do
  describe 'before validation' do
    it 'should create new location when it has coordinates' do
      location = Location.new(coordinates:'1,2')
      location.save.should be true
    end

    it 'should not create new location when it does not have coordinates' do
      location = Location.new()
      location.save.should be false
    end
  end
end

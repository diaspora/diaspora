require 'spec_helper'

describe Event, :type => :model do
  describe "validation" do
    before(:all) do
      @test_name = "name"
      @test_date = "201505251800"
      @test_location = "location"
    end

    it "should create a new event when name, date and location are given" do
      event = Event.new(name: @test_name, date: @test_date, location: @test_location)
      expect(event).to be_valid
    end

    it "should fail to create an event with a missing name" do
      event = Event.new(date: @test_date, location: @test_location)
      expect(event).not_to be_valid
    end

    it "should fail to create an event with a missing date" do
      event = Event.new(name: @test_name, location: @test_location)
      expect(event).not_to be_valid
    end

    it "should fail to create an event with a missing location" do
      event = Event.new(name: @test_name, location: @test_location)
      expect(event).not_to be_valid
    end
  end
end

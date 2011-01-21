require 'spec_helper'

describe DataPoint do

  before do
    @time = Time.now
  end

  context '.posts_per_day_last_week' do
    before(:all) do
      1.times do |n|
        alice.post(:status_message, :message => 'hi', :to => alice.aspects.first)
      end

      5.times do |n|
        bob.post(:status_message, :message => 'hi', :to => bob.aspects.first)
      end
      
      10.times do |n|
        eve.post(:status_message, :message => 'hi', :to => eve.aspects.first)
      end
    end

    it 'returns a DataPoint object' do
      DataPoint.users_with_posts_on_day(@time, 1).class.should == DataPoint
    end

    it 'returns a DataPoint with non-zero value' do
      point = DataPoint.users_with_posts_on_day(@time, 1)
      point.value.should == 1
    end

    it 'returns a DataPoint with zero value' do
      point = DataPoint.users_with_posts_on_day(@time, 15)
      point.value.should == 0
    end
    
    it 'returns the correct descriptor' do
      point = DataPoint.users_with_posts_on_day(Time.now, 15)
      point.key.should == 15.to_s
    end
  end
end

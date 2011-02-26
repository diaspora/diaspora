require 'spec_helper'

describe Statistic do
  before do
    @stat = Statistic.first
    @time = Time.now
  end

  describe '#compute_average' do
    it 'computes the average of all its DataPoints' do
      @stat.compute_average.should == 16.to_f/3
    end
  end

  describe '#distribution' do
    it 'generates a hash' do
      @stat.distribution.class.should == Hash
    end

    it 'correctly sets values' do
      dist = @stat.distribution
      [dist['1'], dist['5'], dist['10']].each do |d|
        d.should == 1.to_f/3
      end
    end

    it 'generates a distribution' do
      values = @stat.distribution.map{|d| d[1]}
      values.inject{ |sum, curr|
        sum += curr
      }.should == 1
    end
  end

  describe '#distribution_as_array' do
    it 'returns an array' do
      @stat.distribution_as_array.class.should == Array
    end

    it 'returns in order' do
      dist = @stat.distribution_as_array
      [dist[1], dist[5], dist[10]].each do |d|
        d.should == 1.to_f/3
      end
    end
  end

  describe '#users_in_sample' do
    it 'returns a count' do
      @stat.users_in_sample.should == 3
    end
  end

  describe '#generate_graph' do
    it 'outputs a binary string' do
      pending "should use google graph API"
      @stat.generate_graph.class.should == String
    end
  end

  describe '.generate' do
    before do
      @time = Time.now - 1.day

      1.times do |n|
        p = alice.post(:status_message, :message => 'hi', :to => alice.aspects.first)
        p.created_at = @time
        p.save
      end

      5.times do |n|
        p = bob.post(:status_message, :message => 'hi', :to => alice.aspects.first)
        p.created_at = @time
        p.save
      end
    end

    it 'creates a Statistic with a default date and range' do
      time = Time.now
      Time.stub!(:now).and_return(time)

      stat = Statistic.generate
      stat.data_points.count.should == 51
      stat.time.should == time
    end

    context 'custom date' do
      before do
        @stat = Statistic.generate(@time)
      end

      it 'creates a Statistic with a custom date' do
        @stat.time.should == @time
      end

      it 'returns only desired sampling' do
        @stat.users_in_sample.should == 2
      end
    end

    context 'custom range' do
      it 'creates a Statistic with a custom range' do
        stat = Statistic.generate(Time.now, (2..32))
        stat.data_points.count.should == 31
      end
    end
  end
end

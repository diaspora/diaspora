#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe RedisCache do
  before do
    #@redis = MockRedis.new
    @redis = Redis.new
    @redis.keys.each{|p| @redis.del(p)}

    @cache = RedisCache.new(bob, :created_at)
    #@cache.stub(:redis).and_return(@redis)
  end

  it 'gets initialized with user and an created_at order' do
    cache = RedisCache.new(bob, :created_at)
    [:@user, :@order_field].each do |var|
      cache.instance_variable_get(var).should_not be_blank
    end
  end

  describe "#cache_exists?" do
    it 'returns true if the sorted set exists' do
      timestamp = Time.now.to_i
      @redis.zadd("cache_stream_#{bob.id}_created_at", timestamp, "post_1")

      @cache.cache_exists?.should be_true
    end

    it 'returns false if there is nothing in the set' do
      @cache.cache_exists?.should be_false
    end
  end

  describe "#post_ids" do
    before do
      @timestamps = []
      @timestamp = Time.now.to_i
      30.times do |n|
        created_time = @timestamp - n*1000
        @redis.zadd("cache_stream_#{bob.id}_created_at", created_time, n)
        @timestamps << created_time
      end
    end

    it 'returns the most recent post ids (default created at, limit 15)' do
      @cache.post_ids.should =~ 15.times.map {|n| n}
    end

    it 'returns posts ids after the specified time' do
      @cache.post_ids(@timestamps[15]).should =~ (15...30).map {|n| n}
    end

    it 'returns post ids with a non-default limit' do
      @cache.post_ids(@timestamp, 20).should =~ 20.times.map {|n| n}
    end
  end

  describe "#ensure_populated!" do
    it 'does nothing if the cache is populated' do
      @cache.stub(:cache_exists?).and_return(true)
      @cache.should_not_receive(:repopulate!)

      @cache.ensure_populated!
    end

    it 'clears and poplulates if the cache is not populated' do
      @cache.stub(:cache_exists?).and_return(false)
      @cache.should_receive(:repopulate!)

      @cache.ensure_populated!
    end
  end

  describe "#repopulate!" do
    it 'populates' do
      @cache.stub(:trim!).and_return(true)
      @cache.should_receive(:populate!).and_return(true)
      @cache.repopulate!
    end

    it 'trims' do
      @cache.stub(:populate!).and_return(true)
      @cache.should_receive(:trim!)
      @cache.repopulate!
    end
  end

  describe "#populate!" do
    it 'queries the db with the visible post sql string' do
      sql = "long_sql"
      order = "created_at DESC"
      @cache.should_receive(:order).and_return(order)
      bob.should_receive(:visible_posts_sql).with(hash_including(
                                                    :limit => 100,
                                                    :order => order)).
                                             and_return(sql)

      Post.connection.should_receive(:select_all).with(sql).and_return([])

      @cache.populate!
    end

    it 'adds the post from the hash to the cache'
  end

  describe "#trim!" do
    it 'does nothing if the set is smaller than the cache limit' do
      @timestamps = []
      @timestamp = Time.now.to_i
      30.times do |n|
        created_time = @timestamp - n*1000
        @redis.zadd("cache_stream_#{bob.id}_created_at", created_time, n)
        @timestamps << created_time
      end

      post_ids = @cache.post_ids(Time.now.to_i, @cache.size)
      @cache.trim!
      @cache.post_ids(Time.now.to_i, @cache.size).should == post_ids
    end

    it 'trims the set to the cache limit' do
      @timestamps = []
      @timestamp = Time.now.to_i
      120.times do |n|
        created_time = @timestamp - n*1000
        @redis.zadd("cache_stream_#{bob.id}_created_at", created_time, n)
        @timestamps << created_time
      end

      post_ids = 100.times.map{|n| n}
      @cache.trim!
      @cache.post_ids(Time.now.to_i, @cache.size).should == post_ids[0...100]
    end
  end

  describe "#add"
  describe "#remove"
end

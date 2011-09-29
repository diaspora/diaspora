#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require 'diaspora/redis_cache'

describe RedisCache do
  before do
    @redis = MockRedis.new
    @cache = RedisCache.new(bob.id, "created_at")
    @cache.stub(:redis).and_return(@redis)
  end

  it 'gets initialized with user_id and an order field' do
    cache = RedisCache.new(bob.id, "updated_at")
    [:@user_id, :@order].each do |var|
      cache.instance_variable_get(var).should_not be_blank
    end
  end

  describe "#cache_exists?" do
    it 'returns true if the sorted set exists' do
      timestamp = Time.now.to_i
      @redis.zadd("cache_stream_#{@bob.id}_created_at", timestamp, "post_1")

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
        @redis.zadd("cache_stream_#{@bob.id}_created_at", created_time, n)
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

  describe "#populate"
  describe "#add"
  describe "#remove"
end

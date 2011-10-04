#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require File.join(Rails.root, 'lib/postzord/receiver')

describe Postzord::Receiver do
  before do
    @receiver = Postzord::Receiver.new
  end

  describe "#perform!" do
    before do
      @receiver.stub(:receive!)
    end

    it 'calls receive!' do
      @receiver.should_receive(:receive!)
      @receiver.perform!
    end

    context 'update_cache!' do
      it "gets called if cache?" do
        @receiver.stub(:cache?).and_return(true)
        @receiver.should_receive(:update_cache!)
        @receiver.perform!
      end

      it "doesn't get called if !cache?" do
        @receiver.stub(:cache?).and_return(false)
        @receiver.should_not_receive(:update_cache!)
        @receiver.perform!
      end
    end
  end

  describe "#cache?" do
    before do
      @receiver.stub(:respond_to?).with(:update_cache!).and_return(true)
      AppConfig[:redis_cache] = true

      RedisCache.stub(:acceptable_types).and_return(["StatusMessage"])
      @receiver.instance_variable_set(:@object, mock(:triggers_caching? => true, :type => "StatusMessage"))
    end

    it 'returns true if the receiver responds to update_cache and the application has caching enabled' do
      @receiver.cache?.should be_true
    end

    it 'returns false if the receiver does not respond to update_cache' do
      @receiver.stub(:respond_to?).with(:update_cache!).and_return(false)
      @receiver.cache?.should be_false
    end

    it 'returns false if the application does not have caching set' do
      AppConfig[:redis_cache] = false
      @receiver.cache?.should be_false
    end

    it 'returns false if the object is does not respond to triggers_caching' do
      @receiver.instance_variable_set(:@object, mock)
      @receiver.cache?.should be_false
    end 

    it 'returns false if the object is not cacheable' do
      @receiver.instance_variable_set(:@object, mock(:triggers_caching? => false))
      @receiver.cache?.should be_false
    end 

    it 'returns false if the object is not of acceptable type for the cache' do
      @receiver.instance_variable_set(:@object, mock(:triggers_caching? => true, :type => "Photo"))
      @receiver.cache?.should be_false
    end
  end
end


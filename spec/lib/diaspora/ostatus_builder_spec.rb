#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root,  'lib/diaspora/ostatus_builder')
require 'nokogiri/xml'

describe Diaspora::OstatusBuilder do

  before do
    @aspect = alice.aspects.first
    @public_status_messages = 3.times.inject([]) do |arr,n|
      s = alice.post(:status_message, :text => "hey#{n}", :public => true, :to => @aspect.id)
      arr << s
    end

    @private_status_messages = 3.times.inject([]) do |arr,n|
      s = alice.post(:status_message, :text => "secret_ney#{n}", :public => false, :to => @aspect.id)
      arr << s
    end

    director = Diaspora::Director.new;
    @atom = director.build(Diaspora::OstatusBuilder.new(alice, @public_status_messages))
  end

  it 'should include a users posts' do
    @public_status_messages.each{ |status| @atom.should include status.text}
  end

  it 'should iterate through all objects, and not stop if it runs into a post without a to_activity' do
    messages = @public_status_messages.collect{|x| x.text}
    @public_status_messages.insert(1, [])
    director = Diaspora::Director.new;
    atom2 = director.build(Diaspora::OstatusBuilder.new(alice, @public_status_messages))
    messages.each{ |message| atom2.should include message }
  end

    include Oink::InstanceTypeCounter
  it 'does not query the db for the author of every post' do
    alice.person #Preload user.person
    ActiveRecord::Base.reset_instance_type_count
    director = Diaspora::Director.new
    messages = StatusMessage.where(:author_id => alice.person.id, :public => true)
    builder = Diaspora::OstatusBuilder.new(alice, messages)
    director.build( builder )
    report_hash["Person"].should be_nil #No people should have been instantiated
  end

  it 'produces a valid atom feed' do
    alice.person #Preload user.person
    ActiveRecord::Base.reset_instance_type_count
    director = Diaspora::Director.new
    messages = StatusMessage.where(:author_id => alice.person.id, :public => true)
    builder = Diaspora::OstatusBuilder.new(alice, messages)
    feed = Nokogiri::XML(director.build( builder ))
    feed_schema = Nokogiri::XML::RelaxNG(File.open(File.join(Rails.root,'spec/fixtures/atom.rng')))
    feed_schema.validate(feed).should be_empty
  end
end


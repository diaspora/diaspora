#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, 'lib/em-webfinger')

describe EMWebfinger do
  let(:user1) { Factory(:user) }
  let(:user2) { Factory(:user) }
  let(:account) {"tom@tom.joindiaspora.com"}
  let(:finger){EMWebfinger.new(account)}

  let(:person){ Factory(:person) }
  let(:good_request) { FakeHttpRequest.new(:success)}
  let(:bad_request) { FakeHttpRequest.new(:failure)}
  let(:stub_good) {EventMachine::HttpRequest.stub!(:new).and_return(good_request)}
  let(:stub_bad) {EventMachine::HttpRequest.stub!(:new).and_return(bad_request)}

  let(:diaspora_xrd) {File.open(File.join(Rails.root, 'spec/fixtures/host_xrd'))}
  let(:diaspora_finger) {File.open(File.join(Rails.root, 'spec/fixtures/finger_xrd'))}
  let(:hcard_xml) {File.open(File.join(Rails.root, 'spec/fixtures/hcard_response'))}
  
                                       
  let(:non_diaspora_xrd) {File.open(File.join(Rails.root, 'spec/fixtures/nonseed_finger_xrd'))}
  let(:non_diaspora_hcard) {File.open(File.join(Rails.root, 'spec/fixtures/evan_hcard'))}

  context 'setup' do
    let(:action){ Proc.new{|person| puts person.inspect }}

    describe '#intialize' do
      it 'sets account ' do
         n = EMWebfinger.new("mbs348@gmail.com")
         n.instance_variable_get(:@account).should_not be nil
      end

      it 'should raise an error on an unresonable email' do
        pending
        proc{EMWebfinger.new("asfadfasdf")}.should raise_error
      end
    end

    describe '#on_person' do 
      it 'should set a callback' do
        n = EMWebfinger.new("mbs@gmail.com")
        n.on_person{|person| puts "foo"}
        n.instance_variable_get(:@callbacks).count.should be 1
      end
    end

    describe '#fetch' do
            
      it 'should require a callback' do
        proc{finger.fetch }.should raise_error "you need to set a callback before calling fetch"
      end
      
      it 'should'
      
    end
  end
  
  context 'webfinger query chain processing' do 
    describe '#webfinger_profile_url' do
        it 'should parse out the webfinger template' do
        finger.webfinger_profile_url(account, diaspora_xrd).should == "http://example.com/webfinger/?q=#{account}"
      end
    end

    describe '#xrd_url' do
      it 'should return canonical host-meta url' do
        finger.xrd_url(account).should be "http://tom.joindiaspora.com/.well-known/host-meta"
      end

      it 'can return the https version' do
        finger.xrd_url(account, true).should be "https://tom.joindiaspora.com/.well-known/host-meta"
      end
    end
  end

  context 'webfingering local people' do
    it 'should return a person from the database if it matches its handle' do
      pending
    end
  end
end

class FakeHttpRequest
  def initialize(callback_wanted)
    @callback = callback_wanted
  end
  def response
  end

  def post; end
  def get; end
  def callback(&b)
    b.call if @callback == :success
  end
  def errback(&b)
    b.call if @callback == :failure
  end
end


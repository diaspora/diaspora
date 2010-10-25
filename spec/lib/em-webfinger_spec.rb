#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require File.join(Rails.root, 'lib/em-webfinger')

describe EMWebfinger do
  let(:user1) { Factory(:user) }
  let(:user2) { Factory(:user) }

  let(:account) {"foo@tom.joindiaspora.com"}
  let(:person){ Factory(:person, :diaspora_handle => account)}
  let(:finger){EMWebfinger.new(account)}


  let(:good_request) { FakeHttpRequest.new(:success)}
  let(:stub_good) {EventMachine::HttpRequest.stub!(:new).and_return(good_request)}
  let(:stub_bad) {EventMachine::HttpRequest.stub!(:new).and_return(bad_request)}

  let(:diaspora_xrd) {File.open(File.join(Rails.root, 'spec/fixtures/host_xrd')).read}
  let(:diaspora_finger) {File.open(File.join(Rails.root, 'spec/fixtures/finger_xrd')).read}
  let(:hcard_xml) {File.open(File.join(Rails.root, 'spec/fixtures/hcard_response')).read}


  let(:non_diaspora_xrd) {File.open(File.join(Rails.root, 'spec/fixtures/nonseed_finger_xrd')).read}
  let(:non_diaspora_hcard) {File.open(File.join(Rails.root, 'spec/fixtures/evan_hcard')).read}

  context 'setup' do
    let(:action){ Proc.new{|person| puts person.inspect }}

    describe '#intialize' do
      it 'sets account ' do
        n = EMWebfinger.new("mbs348@gmail.com")
        n.instance_variable_get(:@account).should_not be nil
      end

      it 'should raise an error on an unresonable email' do
        proc{EMWebfinger.new("asfadfasdf")}.should raise_error
      end
    end

    describe '#on_person' do 
      it 'should set a callback' do
        n = EMWebfinger.new("mbs@gmail.com")
        n.stub(:fetch).and_return(true)

        n.on_person{|person| puts "foo"}
        n.instance_variable_get(:@callbacks).count.should be 1
      end
    end

    describe '#fetch' do
      it 'should require a callback' do
        proc{finger.fetch }.should raise_error "you need to set a callback before calling fetch"
      end
    end

    context 'webfinger query chain processing' do 
      describe '#webfinger_profile_url' do
        it 'should parse out the webfinger template' do
          finger.send(:webfinger_profile_url, diaspora_xrd).should == "http://tom.joindiaspora.com/webfinger/?q=#{account}"
        end
      end

      describe '#xrd_url' do
        it 'should return canonical host-meta url' do
          finger.send(:xrd_url).should == "http://tom.joindiaspora.com/.well-known/host-meta"
        end

        it 'can return the https version' do
          finger.send(:xrd_url, true).should == "https://tom.joindiaspora.com/.well-known/host-meta"
        end

      end
    end

    context 'webfingering local people' do
      it 'should return a person from the database if it matches its handle' do
        person
        EventMachine::HttpRequest.should_not_receive(:new)
        EM.run do
          finger.on_person { |p|
            p.should ==  person
            EM.stop
          }
        end
      end

      it 'should fetch a diaspora webfinger and make a person for them' do
        good_request.callbacks = [diaspora_xrd, diaspora_finger, hcard_xml]

        #new_person = Factory.build(:person, :diaspora_handle => "tom@tom.joindiaspora.com")
                      # http://tom.joindiaspora.com/.well-known/host-meta 
        f = EMWebfinger.new("tom@tom.joindiaspora.com") 

        EventMachine::HttpRequest.should_receive(:new).exactly(3).times.and_return(good_request)
        
        EM.run {
          f.on_person{ |p| 
            p.valid?.should be true 
            EM.stop
          }
        }
      end

    end
  end
end


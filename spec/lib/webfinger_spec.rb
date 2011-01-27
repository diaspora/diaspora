#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require File.join(Rails.root, 'lib/webfinger')

describe Webfinger do
  let(:user1) { alice }
  let(:user2) { eve }

  let(:account) {"foo@tom.joindiaspora.com"}
  let(:person){ Factory(:person, :diaspora_handle => account)}
  let(:finger){Webfinger.new(account)}

  let(:good_request) { FakeHttpRequest.new(:success)}

  let(:diaspora_xrd) {File.open(File.join(Rails.root, 'spec/fixtures/host-meta.fixture.html')).read}
  let(:diaspora_finger) {File.open(File.join(Rails.root, 'spec/fixtures/webfinger.fixture.html')).read}
  let(:hcard_xml) {File.open(File.join(Rails.root, 'spec/fixtures/hcard.fixture.html')).read}


  let(:non_diaspora_xrd) {File.open(File.join(Rails.root, 'spec/fixtures/nonseed_finger_xrd')).read}
  let(:non_diaspora_hcard) {File.open(File.join(Rails.root, 'spec/fixtures/evan_hcard')).read}

  context 'setup' do

    describe '#intialize' do
      it 'sets account ' do
        n = Webfinger.new("mbs348@gmail.com")
        n.instance_variable_get(:@account).should_not be nil
      end

      it 'should set ssl as the default' do
        foo = Webfinger.new(account)
        foo.instance_variable_get(:@ssl).should be true
      end
    end

    context 'webfinger query chain processing' do
      describe '#webfinger_profile_url' do
        it 'should parse out the webfinger template' do
          finger.send(:webfinger_profile_url, diaspora_xrd).should ==
            "http://example.org/webfinger?q=foo@tom.joindiaspora.com"
        end

        it 'should return nil if not an xrd' do
          finger.send(:webfinger_profile_url, '<html></html>').should be nil
        end

        it 'should return the template for xrd' do
          finger.send(:webfinger_profile_url, diaspora_xrd).should ==
            'http://example.org/webfinger?q=foo@tom.joindiaspora.com'
        end
      end

      describe '#xrd_url' do
        it 'should return canonical host-meta url for http' do
          finger.instance_variable_set(:@ssl, false)
          finger.send(:xrd_url).should == "http://tom.joindiaspora.com/.well-known/host-meta"
        end

        it 'can return the https version' do
          finger.send(:xrd_url).should == "https://tom.joindiaspora.com/.well-known/host-meta"
        end
      end
    end


    context 'webfingering local people' do
      it 'should return a person from the database if it matches its handle' do
        person.save
        finger.fetch.id.should == person.id
      end
    end
    it 'should fetch a diaspora webfinger and make a person for them' do
      diaspora_xrd.stub!(:body).and_return(diaspora_xrd)
      hcard_xml.stub!(:body).and_return(hcard_xml)
      diaspora_finger.stub!(:body).and_return(diaspora_finger)
      RestClient.stub!(:get).and_return(diaspora_xrd, diaspora_finger, hcard_xml)
      #new_person = Factory.build(:person, :diaspora_handle => "tom@tom.joindiaspora.com")
      # http://tom.joindiaspora.com/.well-known/host-meta
      f = Webfinger.new("alice@example.org").fetch

      f.should be_valid
    end

    it 'should retry with http if https fails' do
      f = Webfinger.new("tom@tom.joindiaspora.com")

      diaspora_xrd.stub!(:body).and_return(diaspora_xrd)
      RestClient.should_receive(:get).twice.and_return(nil, diaspora_xrd)
      f.should_receive(:xrd_url).twice
      f.send(:get_xrd)
      f.instance_variable_get(:@ssl).should == false
    end

  end
end

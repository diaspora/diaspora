#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require File.join(Rails.root, 'lib/webfinger')

describe Webfinger do
  let(:host_with_port) { "#{AppConfig.pod_uri.host}:#{AppConfig.pod_uri.port}" }
  let(:user1) { alice }
  let(:user2) { eve }

  let(:account) { "foo@tom.joindiaspora.com" }
  let(:person) { Factory(:person, :diaspora_handle => account) }
  let(:finger) { Webfinger.new(account) }

  let(:good_request) { FakeHttpRequest.new(:success) }

  let(:diaspora_xrd) { File.open(File.join(Rails.root, 'spec', 'fixtures', 'host-meta.fixture.html')).read }
  let(:diaspora_finger) { File.open(File.join(Rails.root, 'spec', 'fixtures', 'webfinger.fixture.html')).read }
  let(:hcard_xml) { File.open(File.join(Rails.root, 'spec', 'fixtures', 'hcard.fixture.html')).read }

  context 'setup' do

    describe '#intialize' do
      it 'sets account ' do
        n = Webfinger.new("mbs348@gmail.com")
        n.instance_variable_get(:@account).should_not be nil
      end

      it 'downcases account' do
        account = "BIGBOY@Example.Org"
        n = Webfinger.new(account)
        n.instance_variable_get(:@account).should == account.downcase
      end

      it 'should set ssl as the default' do
        foo = Webfinger.new(account)
        foo.instance_variable_get(:@ssl).should be true
      end
    end

    context 'webfinger query chain processing' do
      describe '#webfinger_profile_url' do
        it 'parses out the webfinger template' do
          finger.send(:webfinger_profile_url, diaspora_xrd).should ==
            "http://#{host_with_port}/webfinger?q=foo@tom.joindiaspora.com"
        end

        it 'should return nil if not an xrd' do
          finger.send(:webfinger_profile_url, '<html></html>').should be nil
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

    describe '#get_xrd' do
      it 'follows redirects' do
        redirect_url = "http://whereami.whatisthis/host-meta"
        stub_request(:get, "https://tom.joindiaspora.com/.well-known/host-meta").
          to_return(:status => 302, :headers => { 'Location' => redirect_url })
        stub_request(:get, redirect_url).
          to_return(:status => 200, :body => diaspora_xrd)
        begin
        finger.send :get_xrd
        rescue; end
        a_request(:get, redirect_url).should have_been_made
      end
    end


    context 'webfingering local people' do
      it 'should return a person from the database if it matches its handle' do
        person.save
        finger.fetch.id.should == person.id
      end
    end
    it 'should fetch a diaspora webfinger and make a person for them' do
      User.delete_all; Person.delete_all; Profile.delete_all
      hcard_url = "http://google-1655890.com/hcard/users/29a9d5ae5169ab0b"

      f = Webfinger.new("alice@#{host_with_port}")
      stub_request(:get, f.send(:xrd_url)).
        to_return(:status => 200, :body => diaspora_xrd, :headers => {})
      stub_request(:get, f.send(:webfinger_profile_url, diaspora_xrd)).
        to_return(:status => 200, :body => diaspora_finger, :headers => {})
      f.should_receive(:hcard_url).and_return(hcard_url)

      stub_request(:get, hcard_url).
        to_return(:status => 200, :body => hcard_xml, :headers => {})

      person = f.fetch

      WebMock.should have_requested(:get, f.send(:xrd_url))
      WebMock.should have_requested(:get, f.send(:webfinger_profile_url, diaspora_xrd))
      WebMock.should have_requested(:get, hcard_url)
      person.should be_valid
    end

    it 'should retry with http if https fails' do
      f = Webfinger.new("tom@tom.joindiaspora.com")
      xrd_url = "://tom.joindiaspora.com/.well-known/host-meta"

      stub_request(:get, "https#{xrd_url}").
        to_return(:status => 503, :body => "", :headers => {})
      stub_request(:get, "http#{xrd_url}").
        to_return(:status => 200, :body => diaspora_xrd, :headers => {})

      #Faraday::Connection.any_instance.should_receive(:get).twice.and_return(nil, diaspora_xrd)
      f.send(:get_xrd)
      WebMock.should have_requested(:get,"https#{xrd_url}")
      WebMock.should have_requested(:get,"http#{xrd_url}")
      f.instance_variable_get(:@ssl).should == false
    end

  end
end

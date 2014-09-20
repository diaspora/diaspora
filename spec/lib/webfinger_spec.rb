#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Webfinger do
  let(:host_meta_xrd) { File.open(Rails.root.join('spec', 'fixtures', 'host-meta.fixture.html')).read }
  let(:webfinger_xrd) { File.open(Rails.root.join('spec', 'fixtures', 'webfinger.fixture.html')).read }
  let(:hcard_xml) { File.open(Rails.root.join('spec', 'fixtures', 'hcard.fixture.html')).read }
  let(:account){'foo@bar.com'}
  let(:account_in_fixtures){"alice@localhost:9887"}
  let(:finger){Webfinger.new(account)}
  let(:host_meta_url){"http://#{AppConfig.pod_uri.authority}/webfinger?q="}

  describe '#intialize' do
    it 'sets account ' do
      n = Webfinger.new("mbs348@gmail.com")
      expect(n.account).not_to be nil
    end

    it "downcases account and strips whitespace, and gsub 'acct:'" do
      n = Webfinger.new("acct:BIGBOY@Example.Org ")
      expect(n.account).to eq('bigboy@example.org')
    end

    it 'should set ssl as the default' do
      foo = Webfinger.new(account)
      expect(foo.ssl).to be true
    end
  end

  describe '.in_background' do
    it 'enqueues a Workers::FetchWebfinger job' do
      expect(Workers::FetchWebfinger).to receive(:perform_async).with(account)
      Webfinger.in_background(account)
    end
  end

  describe '#fetch' do
    it 'works' do
      finger = Webfinger.new(account_in_fixtures)
      allow(finger).to receive(:host_meta_xrd).and_return(host_meta_xrd)
      allow(finger).to receive(:hcard_xrd).and_return(hcard_xml)
      allow(finger).to receive(:webfinger_profile_xrd).and_return(webfinger_xrd)
      person = finger.fetch
      expect(person).to be_valid
      expect(person).to be_a Person
    end

  end

  describe '#get' do
    it 'makes a request and grabs the body' do
      url ="https://bar.com/.well-known/host-meta"
      stub_request(:get, url).
        to_return(:status => 200, :body => host_meta_xrd)

      expect(finger.get(url)).to eq(host_meta_xrd)
    end

    it 'follows redirects' do
      redirect_url = "http://whereami.whatisthis/host-meta"

      stub_request(:get, "https://bar.com/.well-known/host-meta").
        to_return(:status => 302, :headers => { 'Location' => redirect_url })

      stub_request(:get, redirect_url).
        to_return(:status => 200, :body => host_meta_xrd)

      finger.host_meta_xrd

      expect(a_request(:get, redirect_url)).to have_been_made
    end

    it 'raises on 404' do
      url ="https://bar.com/.well-known/host-meta"
      stub_request(:get, url).
        to_return(:status => 404, :body => nil)

      expect {
        expect(finger.get(url)).to eq(false)
      }.to raise_error
    end
  end

  describe 'existing_person_with_profile?' do
    it 'returns true if cached_person is present and has a profile' do
      expect(finger).to receive(:cached_person).twice.and_return(FactoryGirl.create(:person))
      expect(finger.existing_person_with_profile?).to be true
    end

    it 'returns false if it has no person' do
      allow(finger).to receive(:cached_person).and_return false
      expect(finger.existing_person_with_profile?).to be false
    end

    it 'returns false if the person has no profile' do
      p = FactoryGirl.create(:person)
      p.profile = nil
      allow(finger).to receive(:cached_person).and_return(p)
      expect(finger.existing_person_with_profile?).to be false
    end
  end

  describe 'cached_person' do
    it 'sets the person by looking up the account from Person.by_account_identifier' do
      person = double
      expect(Person).to receive(:by_account_identifier).with(account).and_return(person)
      expect(finger.cached_person).to eq(person)
      expect(finger.person).to eq(person)
    end
  end


  describe 'create_or_update_person_from_webfinger_profile!' do
    context 'with a cached_person' do
      it 'calls Person#assign_new_profile_from_hcard with the fetched hcard' do
        finger.hcard_xrd = hcard_xml
        allow(finger).to receive(:person).and_return(bob.person)
        expect(bob.person).to receive(:assign_new_profile_from_hcard).with(finger.hcard)
        finger.create_or_update_person_from_webfinger_profile!
      end
    end

    context 'with no cached person' do
      it 'sets person based on make_person_from_webfinger' do
        allow(finger).to receive(:person).and_return(nil)
        expect(finger).to receive(:make_person_from_webfinger)
        finger.create_or_update_person_from_webfinger_profile!
      end
    end
  end

  describe '#host_meta_xrd' do
    it 'calls #get with host_meta_url' do
      allow(finger).to receive(:host_meta_url).and_return('meta')
      expect(finger).to receive(:get).with('meta')
      finger.host_meta_xrd
    end

    it 'should retry with ssl off a second time' do
      expect(finger).to receive(:get).and_raise(StandardError)
      expect(finger).to receive(:get)
      finger.host_meta_xrd
      expect(finger.ssl).to be false
    end
  end

  describe '#hcard' do
    it 'calls HCard.build' do
      allow(finger).to receive(:hcard_xrd).and_return(hcard_xml)
      expect(HCard).to receive(:build).with(hcard_xml).and_return true
      expect(finger.hcard).not_to be_nil
    end
  end

  describe '#webfinger_profile' do
    it 'constructs a new WebfingerProfile object' do
      allow(finger).to receive(:webfinger_profile_xrd).and_return(webfinger_xrd)
      expect(WebfingerProfile).to receive(:new).with(account, webfinger_xrd)
      finger.webfinger_profile
    end
  end

  describe '#webfinger_profile_url' do
    it 'returns the llrd link for a valid host meta' do
      allow(finger).to receive(:host_meta_xrd).and_return(host_meta_xrd)
      expect(finger.webfinger_profile_url).not_to be_nil
    end

    it 'returns nil if no link is found' do
      allow(finger).to receive(:host_meta_xrd).and_return(nil)
      expect(finger.webfinger_profile_url).to be_nil
    end
  end

  describe '#webfinger_profile_xrd' do
    it 'calls #get with the hcard_url' do
      allow(finger).to receive(:hcard_url).and_return("url")
      expect(finger).to receive(:get).with("url")
      finger.hcard_xrd
    end
  end

  describe '#make_person_from_webfinger' do
    it 'with an hcard and a webfinger_profile, it calls Person.create_from_webfinger' do
      allow(finger).to receive(:hcard).and_return("hcard")
      allow(finger).to receive(:webfinger_profile_xrd).and_return("webfinger_profile_xrd")
      allow(finger).to receive(:webfinger_profile).and_return("webfinger_profile")
      expect(Person).to receive(:create_from_webfinger).with("webfinger_profile", "hcard")
      finger.make_person_from_webfinger
    end

    it 'with an false xrd it does not call Person.create_from_webfinger' do
      allow(finger).to receive(:webfinger_profile_xrd).and_return(false)
      expect(Person).not_to receive(:create_from_webfinger)
      finger.make_person_from_webfinger
    end
  end



  describe '#host_meta_url' do
    it 'should return canonical host-meta url for http' do
      finger.ssl = false
      expect(finger.host_meta_url).to eq("http://bar.com/.well-known/host-meta")
    end

    it 'can return the https version' do
      expect(finger.host_meta_url).to eq("https://bar.com/.well-known/host-meta")
    end
  end

  describe 'swizzle' do
    it 'gsubs out {uri} for the account' do
      string = "{uri} is the coolest"
      expect(finger.swizzle(string)).to eq("#{finger.account} is the coolest")
    end
  end
end

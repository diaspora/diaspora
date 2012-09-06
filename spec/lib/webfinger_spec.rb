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
  let(:host_meta_url){"http://#{AppConfig[:pod_uri].authority}/webfinger?q="}

  describe '#intialize' do
    it 'sets account ' do
      n = Webfinger.new("mbs348@gmail.com")
      n.account.should_not be nil
    end

    it "downcases account and strips whitespace, and gsub 'acct:'" do
      n = Webfinger.new("acct:BIGBOY@Example.Org ")
      n.account.should == 'bigboy@example.org'
    end

    it 'should set ssl as the default' do
      foo = Webfinger.new(account)
      foo.ssl.should be true
    end
  end

  describe '.in_background' do
    it 'enqueues a Jobs::FetchWebfinger job' do
      Resque.should_receive(:enqueue).with(Jobs::FetchWebfinger, account)
      Webfinger.in_background(account)
    end
  end
  
  describe '#fetch' do
    it 'works' do
      finger = Webfinger.new(account_in_fixtures)
      finger.stub(:host_meta_xrd).and_return(host_meta_xrd)
      finger.stub(:hcard_xrd).and_return(hcard_xml)
      finger.stub(:webfinger_profile_xrd).and_return(webfinger_xrd)
      person = finger.fetch
      person.should be_valid
      person.should be_a Person
    end

  end

  describe '#get' do
    it 'makes a request and grabs the body' do
      url ="https://bar.com/.well-known/host-meta"
      stub_request(:get, url).
        to_return(:status => 200, :body => host_meta_xrd)

      finger.get(url).should == host_meta_xrd
    end

    it 'follows redirects' do
      redirect_url = "http://whereami.whatisthis/host-meta"

      stub_request(:get, "https://bar.com/.well-known/host-meta").
        to_return(:status => 302, :headers => { 'Location' => redirect_url })

      stub_request(:get, redirect_url).
        to_return(:status => 200, :body => host_meta_xrd)

      finger.host_meta_xrd

      a_request(:get, redirect_url).should have_been_made
    end
    
    it 'returns false on 404' do
      url ="https://bar.com/.well-known/host-meta"
      stub_request(:get, url).
        to_return(:status => 404, :body => nil)

      finger.get(url).should_not == nil
      finger.get(url).should == false
    end
  end

  describe 'existing_person_with_profile?' do
    it 'returns true if cached_person is present and has a profile' do
      finger.should_receive(:cached_person).twice.and_return(FactoryGirl.create(:person))
      finger.existing_person_with_profile?.should be_true
    end

    it 'returns false if it has no person' do
      finger.stub(:cached_person).and_return false
      finger.existing_person_with_profile?.should be_false
    end

    it 'returns false if the person has no profile' do
      p = FactoryGirl.create(:person)
      p.profile = nil
      finger.stub(:cached_person).and_return(p)
      finger.existing_person_with_profile?.should be_false
    end
  end

  describe 'cached_person' do
    it 'sets the person by looking up the account from Person.by_account_identifier' do
      person = stub
      Person.should_receive(:by_account_identifier).with(account).and_return(person)
      finger.cached_person.should == person
      finger.person.should == person
    end
  end


  describe 'create_or_update_person_from_webfinger_profile!' do
    context 'with a cached_person' do
      it 'calls Person#assign_new_profile_from_hcard with the fetched hcard' do
        finger.hcard_xrd = hcard_xml
        finger.stub(:person).and_return(bob.person)
        bob.person.should_receive(:assign_new_profile_from_hcard).with(finger.hcard)
        finger.create_or_update_person_from_webfinger_profile!
      end
    end

    context 'with no cached person' do
      it 'sets person based on make_person_from_webfinger' do
        finger.stub(:person).and_return(nil)
        finger.should_receive(:make_person_from_webfinger)
        finger.create_or_update_person_from_webfinger_profile!
      end
    end
  end

  describe '#host_meta_xrd' do
    it 'calls #get with host_meta_url' do
      finger.stub(:host_meta_url).and_return('meta')
      finger.should_receive(:get).with('meta')
      finger.host_meta_xrd
    end

    it 'should retry with ssl off a second time' do
      finger.should_receive(:get).and_raise(StandardError)
      finger.should_receive(:get)
      finger.host_meta_xrd
      finger.ssl.should be false
    end
  end

  describe '#hcard' do
    it 'calls HCard.build' do
      finger.stub(:hcard_xrd).and_return(hcard_xml)
      HCard.should_receive(:build).with(hcard_xml).and_return true
      finger.hcard.should_not be_nil
    end
  end

  describe '#webfinger_profile' do
    it 'constructs a new WebfingerProfile object' do
      finger.stub(:webfinger_profile_xrd).and_return(webfinger_xrd)
      WebfingerProfile.should_receive(:new).with(account, webfinger_xrd)
      finger.webfinger_profile
    end
  end

  describe '#webfinger_profile_url' do
    it 'returns the llrd link for a valid host meta' do
      finger.stub(:host_meta_xrd).and_return(host_meta_xrd)
      finger.webfinger_profile_url.should_not be_nil
    end

    it 'returns nil if no link is found' do
      finger.stub(:host_meta_xrd).and_return(nil)
      finger.webfinger_profile_url.should be_nil
    end
  end

  describe '#webfinger_profile_xrd' do
    it 'calls #get with the hcard_url' do
      finger.stub(:hcard_url).and_return("url")
      finger.should_receive(:get).with("url")
      finger.hcard_xrd
    end
  end

  describe '#make_person_from_webfinger' do
    it 'with an hcard and a webfinger_profile, it calls Person.create_from_webfinger' do
      finger.stub(:hcard).and_return("hcard")
      finger.stub(:webfinger_profile_xrd).and_return("webfinger_profile_xrd")
      finger.stub(:webfinger_profile).and_return("webfinger_profile")
      Person.should_receive(:create_from_webfinger).with("webfinger_profile", "hcard")
      finger.make_person_from_webfinger
    end
    
    it 'with an false xrd it does not call Person.create_from_webfinger' do
      finger.stub(:webfinger_profile_xrd).and_return(false)
      Person.should_not_receive(:create_from_webfinger)
      finger.make_person_from_webfinger
    end
  end



  describe '#host_meta_url' do
    it 'should return canonical host-meta url for http' do
      finger.ssl = false
      finger.host_meta_url.should == "http://bar.com/.well-known/host-meta"
    end

    it 'can return the https version' do
      finger.host_meta_url.should == "https://bar.com/.well-known/host-meta"
    end
  end

  describe 'swizzle' do
    it 'gsubs out {uri} for the account' do
      string = "{uri} is the coolest"
      finger.swizzle(string).should == "#{finger.account} is the coolest"
    end
  end
end

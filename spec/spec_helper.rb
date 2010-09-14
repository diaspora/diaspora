#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.

ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)
require 'rspec/rails'
require 'database_cleaner'
require 'webmock/rspec'

include Devise::TestHelpers
include WebMock



# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :mocha
  config.mock_with :rspec

  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.orm = "mongo_mapper"

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    stub_signature_verification

  end

  config.before(:each) do
    DatabaseCleaner.start
    stub_sockets
    User.stub!(:allowed_email?).and_return(:true)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
  def stub_sockets
    Diaspora::WebSocket.stub!(:push_to_user).and_return(true)
    Diaspora::WebSocket.stub!(:subscribe).and_return(true)
    Diaspora::WebSocket.stub!(:unsubscribe).and_return(true)
  end

  def stub_signature_verification
    (get_models.map{|model| model.camelize.constantize} - [User]).each do |model|
      model.any_instance.stubs(:verify_signature).returns(true)
    end
  end

  def unstub_mocha_stubs
    Mocha::Mockery.instance.stubba.unstub_all
  end

  def get_models
    models = []
    Dir.glob( File.dirname(__FILE__) + '/../app/models/*' ).each do |f|
      models << File.basename( f ).gsub( /^(.+).rb/, '\1')
    end
    models
  end

  def message_queue
    User::QUEUE
  end

  def friend_users(user1, aspect1, user2, aspect2)
    request = user1.send_friend_request_to(user2.person, aspect1)
    reversed_request = user2.accept_friend_request( request.id, aspect2.id) 
    user1.receive reversed_request.to_diaspora_xml
  end

  def stub_success(address = 'abc@example.com')
    host = address.split('@')[1]
    stub_request(:get, "https://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, "http://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    if host.include?("joindiaspora.com")
      stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 200, :body => finger_xrd)
      stub_request(:get, "http://#{host}/hcard/users/4c8eccce34b7da59ff000002").to_return(:status => 200, :body => hcard_response)
    else
      stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 200, :body => nonseed_finger_xrd)
      stub_request(:get, 'http://evan.status.net/hcard').to_return(:status => 200, :body => evan_hcard)
    end
  end

  def stub_failure(address = 'abc@example.com')
    host = address.split('@')[1]
    stub_request(:get, "https://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, "http://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 500)
  end

  def host_xrd
    <<-XML
  <?xml version='1.0' encoding='UTF-8'?>
  <XRD xmlns='http://docs.oasis-open.org/ns/xri/xrd-1.0'>
    <Link rel='lrdd' 
          template='http://example.com/webfinger/?q={uri}'>
      <Title>Resource Descriptor</Title>
    </Link>
  </XRD>
    XML
  end

  def finger_xrd
    <<-XML
    <?xml version='1.0'?>
    <XRD>
    <Subject>acct:tom@tom.joindiaspora.com</Subject>
    <Alias>"http://tom.joindiaspora.com/"</Alias>
    <Link rel="http://microformats.org/profile/hcard" type="text/html" href="http://tom.joindiaspora.com/hcard/users/4c8eccce34b7da59ff000002"/>
    <Link rel="http://joindiaspora.com/seed_location" type="text/html" href="http://tom.joindiaspora.com/"/>
    <Link rel="http://joindiaspora.com/guid" type="text/html" href="4c8eccce34b7da59ff000002"/>
    <Link rel="diaspora-public-key" type="RSA" href="LS0tLS1CRUdJTiBSU0EgUFVCTElDIEtFWS0tLS0tCk1JSUNDZ0tDQWdFQXlt dHpUdWQ3SytXQklPVVYwMmxZN2Z1NjdnNWQrbTBra1ZIQlgzTk1uYXB5bnZL a0VSemoKbkxma2JrTVpEVGdPNG1UaThmWFI3Q1ZSK3Q1SFN4b2Vub0JWazVX eUFabkEzWmpTRjBPcC9RakhlYzhvK0dVSApDOFluNFJ5N01hQ0R1cUNpNnJv c2RlbUlLTm1Fa2dsVVY1VzZ4WFd4Vmtrb21oL2VCQ2FmaVdMTXFRMG82NGox Ckw3aXNjQjVOM3ZkbnBrUmU3SkFxLzNDUTI3dWhDS0ZIWG1JYm1iVmhJQTNC R0J6YStPV3NjK1Z5cjV0Mm1wSlIKU1RXMk9UL20rS0NPK21kdnpmenQ0TzEr UHc1M1pJMjRpMlc2cW1XdThFZ1Z6QVcyMStuRGJManZiNHpzVHlrNQppN1JM cG8rUFl2VUJlLy8wM1lkQUJoRlJhVXpTL0RtcWRubEVvb0VvK0VmYzRkQ1NF bWVkMUgrek01c2xqQm1rCks5amsvOHNQZDB0SVZmMWZXdW9BcWZTSmErSXdr OHNybkdZbEVlaFV1dVhIY0x2b2JlUXJKYWdiRGc1Qll5TnIKeTAzcHpKTHlS ZU9UcC9RK1p0TXpMOFJMZWJsUzlWYXdNQzNDVzc5K0RGditTWGZ0eTl3NC8w d2NpUHpKejg2bgp2VzJ5K3crTThOWG52enBWNU81dGI4azZxZ2N0WjBmRzFu eXQ0RklsSHNVaUVoNnZLZmNLSmFPeWFRSGNGcWVxCjkwUkpoMm9TMDJBdFJx TFRSWDJJQjFnYXZnWEFXN1NYanJNbUNlVzlCdVBKYU5nZkp3WFFaelVoa0tC V1k0VnMKZTRFVWRob3R5RWkvUmE0RXVZU01ZcnZEeUFRUHJsY0wveDliaU1p bHVPcU9OMEpJZ1VodEZQRUNBd0VBQVE9PQotLS0tLUVORCBSU0EgUFVCTElD IEtFWS0tLS0tCg== "/>
    </XRD>
    XML
  end

  def hcard_response
    <<-FOO
   <div id="content"> 
  <h1>Alexander Hamiltom</h1> 
  <div id="content_inner"> 
    <div id="i" class="entity_profile vcard author"> 
      <h2>User profile</h2> 
      <dl class="entity_nickname"> 
        <dt>Nickname</dt> 
        <dd> 
        <a href="http://tom.joindiaspora.com/" rel="me" class="nickname url uid">Alexander Hamiltom</a> 
        </dd> 
      </dl> 
        <dl class="entity_given_name"> 
        <dt>Full name</dt> 
        <dd> 
        <span class="given_name" >Alexander</span> 
        </dd> 
        </dl>

        <dl class="entity_family_name"> 
        <dt>Full name</dt> 
        <dd> 
        <span class="family_name" >Hamiltom</span> 
        </dd> 
        </dl>
        <dl class="entity_fn"> 
        <dt>Full name</dt> 
        <dd> 
        <span class="fn" >Alexander Hamiltom</span> 
        </dd> 
      </dl> 
      <dl class="entity_url"> 
        <dt>URL</dt> 
        <dd> 
        <a href="http://tom.joindiaspora.com/" rel="me" id="pod_location" class="url">http://tom.joindiaspora.com/</a> 
        </dd> 
      </dl> 
      <dl class="entity_note"> 
        <dt>Note</dt> 
        <dd class="note">Diaspora is awesome! vi is better than emacs!</dd> 
      </dl> 
    </div> 
  </div> 

</div> 

    FOO
  end

  def nonseed_finger_xrd
    <<-XML
      <XRD>
      <Subject>acct:evan@status.net</Subject>
      <Alias>acct:evan@evan.status.net</Alias>
      <Alias>http://evan.status.net/user/1</Alias>
      <Link rel="http://webfinger.net/rel/profile-page" type="text/html" href="http://evan.status.net/user/1"/>
      <Link rel="http://schemas.google.com/g/2010#updates-from" href="http://evan.status.net/api/statuses/user_timeline/1.atom" type="application/atom+xml"/>
      <Link rel="http://microformats.org/profile/hcard" type="text/html" href="http://evan.status.net/hcard"/>
      <Link rel="http://gmpg.org/xfn/11" type="text/html" href="http://evan.status.net/user/1"/>
      <Link rel="describedby" type="application/rdf+xml" href="http://evan.status.net/foaf"/>
      <Link rel="salmon" href="http://evan.status.net/main/salmon/user/1"/>
      <Link rel="http://salmon-protocol.org/ns/salmon-replies" href="http://evan.status.net/main/salmon/user/1"/>
      <Link rel="http://salmon-protocol.org/ns/salmon-mention" href="http://evan.status.net/main/salmon/user/1"/>
      <Link rel="magic-public-key" href="data:application/magic-public-key,RSA.vyohOlwX03oJUg6R8BQP4V-6QQUfPg9gzOwk3ENQjqeGorHN8RNI4rhCQp7tACe9DEdEKtzZHbSvQC2zRICQ9JG_SIcpiU9jcT2imN5cPLZZQuPFZWwG4xPu_8LKRHuXeLGkzQMjvg6jFBl7qdo_iPnlbtIBb-mEuAnfRMcdUPE=.AQAB"/>
      <Link rel="http://ostatus.org/schema/1.0/subscribe" template="http://evan.status.net/main/ostatussub?profile={uri}"/>
      </XRD>
    XML
  end

  def evan_hcard
    <<-HCARD
    <body id="hcard">

  <div id="wrap">
   <div id="core">
    <dl id="site_nav_local_views">
     <dt>Local views</dt>
     <dd></dd>
</dl>
    <div id="content">
     <h1>Evan Prodromou</h1>

     <div id="content_inner">
      <div id="i" class="entity_profile vcard author">
       <h2>User profile</h2>
       <dl class="entity_depiction">
        <dt>Photo</dt>
        <dd>
         <img src="http://avatar.status.net/evan/1-96-20100726204409.jpeg" class="photo avatar" width="96" height="96" alt="evan"/>
</dd>

</dl>
       <dl class="entity_nickname">
        <dt>Nickname</dt>
        <dd>
         <a href="http://evan.status.net/" rel="me" class="nickname url uid">evan</a>
</dd>
</dl>
       <dl class="entity_fn">
        <dt>Full name</dt>

        <dd>
         <span class="fn">Evan Prodromou</span>
</dd>
</dl>
       <dl class="entity_location">
        <dt>Location</dt>
        <dd class="label">Montreal, QC, Canada</dd>
</dl>
       <dl class="entity_url">

        <dt>URL</dt>
        <dd>
         <a href="http://evan.prodromou.name/" rel="me" class="url">http://evan.prodromou.name/</a>
</dd>
</dl>
       <dl class="entity_note">
        <dt>Note</dt>
        <dd class="note">Montreal hacker and entrepreneur. Founder of identi.ca, lead developer of StatusNet, CEO of StatusNet Inc.</dd>

</dl>
</div>
</div>
</div>
</div>
   <div id="footer">
    <dl id="licenses">
     <dt id="site_statusnet_license">StatusNet software license</dt>
     <dd><p><strong>Evan Prodromou</strong> is a microblogging service brought to you by <a href="http://status.net/">Status.net</a>. It runs the <a href="http://status.net/">StatusNet</a> microblogging software, version 0.9.5, available under the <a href="http://www.fsf.org/licensing/licenses/agpl-3.0.html">GNU Affero General Public License</a>.</p>

</dd>
     <dt id="site_content_license">Site content license</dt>
     <dd id="site_content_license_cc">
      <p>
       <img id="license_cc" src="http://i.creativecommons.org/l/by/3.0/80x15.png" alt="Creative Commons Attribution 3.0" width="80" height="15"/>
 All Evan Prodromou content and data are available under the <a class="license" rel="external license" href="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0</a> license.</p>
</dd>

</dl>
</div>
</div>
</body>
  HCARD
 
  end

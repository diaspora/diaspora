#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PublicsController, :type => :controller do
  let(:fixture_path) { Rails.root.join('spec', 'fixtures') }
  before do
    @user = alice
    @person = FactoryGirl.create(:person)
  end

  describe '#receive_public' do
    it 'succeeds' do
      post :receive_public, :xml => "<stuff/>"
      expect(response).to be_success
    end

    it 'returns a 422 if no xml is passed' do
      post :receive_public
      expect(response.code).to eq('422')
    end

    it 'enqueues a ReceiveUnencryptedSalmon job' do
      xml = "stuff"
      expect(Workers::ReceiveUnencryptedSalmon).to receive(:perform_async).with(xml)
      post :receive_public, :xml => xml
    end
  end

  describe '#receive' do
    let(:xml) { "<walruses></walruses>" }

    it 'succeeds' do
      post :receive, "guid" => @user.person.guid.to_s, "xml" => xml
      expect(response).to be_success
    end

    it 'enqueues a receive job' do
      expect(Workers::ReceiveEncryptedSalmon).to receive(:perform_async).with(@user.id, xml).once
      post :receive, "guid" => @user.person.guid.to_s, "xml" => xml
    end

    it 'unescapes the xml before sending it to receive_salmon' do
      aspect = @user.aspects.create(:name => 'foo')
      post1 = @user.post(:status_message, :text => 'moms', :to => [aspect.id])
      xml2 = post1.to_diaspora_xml
      user2 = FactoryGirl.create(:user)

      salmon_factory = Salmon::EncryptedSlap.create_by_user_and_activity(@user, xml2)
      enc_xml = salmon_factory.xml_for(user2.person)

      expect(Workers::ReceiveEncryptedSalmon).to receive(:perform_async).with(@user.id, enc_xml).once
      post :receive, "guid" => @user.person.guid.to_s, "xml" => CGI::escape(enc_xml)
    end

    it 'returns a 422 if no xml is passed' do
      post :receive, "guid" => @person.guid.to_s
      expect(response.code).to eq('422')
    end

    it 'returns a 404 if no user is found' do
      post :receive, "guid" => @person.guid.to_s, "xml" => xml
      expect(response).to be_not_found
    end
    it 'returns a 404 if no person is found' do
      post :receive, :guid => '2398rq3948yftn', :xml => xml
      expect(response).to be_not_found
    end
  end

  describe '#hub' do
    it 'succeeds' do
      get :hub
      expect(response).to be_success
    end
  end
end

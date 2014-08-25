#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Postzord::Receiver::Private do

  before do
    @alices_post = alice.build_post(:status_message, :text => "hey", :aspect_ids => [alice.aspects.first.id])
    @salmon_xml = alice.salmon(@alices_post).xml_for(bob.person)
  end

  describe '.initialize' do
    it 'valid for local' do
      expect(Webfinger).not_to receive(:new)
      expect(Salmon::EncryptedSlap).not_to receive(:from_xml)

      zord = Postzord::Receiver::Private.new(bob, :person => alice.person, :object => @alices_post)
      expect(zord.instance_variable_get(:@user)).not_to be_nil
      expect(zord.instance_variable_get(:@sender)).not_to be_nil
      expect(zord.instance_variable_get(:@object)).not_to be_nil
    end

    it 'valid for remote' do
      salmon_double = double()
      web_double = double()
      expect(web_double).to receive(:fetch).and_return true
      expect(salmon_double).to receive(:author_id).and_return(true)
      expect(Salmon::EncryptedSlap).to receive(:from_xml).with(@salmon_xml, bob).and_return(salmon_double)
      expect(Webfinger).to receive(:new).and_return(web_double)

      zord = Postzord::Receiver::Private.new(bob, :salmon_xml => @salmon_xml)
      expect(zord.instance_variable_get(:@user)).not_to be_nil
      expect(zord.instance_variable_get(:@sender)).not_to be_nil
      expect(zord.instance_variable_get(:@salmon_xml)).not_to be_nil
    end
  end

  describe '#receive!' do
    before do
      @zord = Postzord::Receiver::Private.new(bob, :salmon_xml => @salmon_xml)
      @salmon = @zord.instance_variable_get(:@salmon)
    end

    context 'returns false' do
      it 'if the salmon author does not exist' do
        @zord.instance_variable_set(:@sender, nil)
        expect(@zord.receive!).to eq(false)
      end

      it 'if the author does not match the signature' do
        @zord.instance_variable_set(:@sender, FactoryGirl.create(:person))
        expect(@zord.receive!).to eq(false)
      end
    end

    context 'returns the sent object' do
      it 'returns the received object on success' do
        @zord.receive!
        expect(@zord.instance_variable_get(:@object)).to respond_to(:to_diaspora_xml)
      end
    end

    it 'parses the salmon object' do
      expect(Diaspora::Parser).to receive(:from_xml).with(@salmon.parsed_data).and_return(@alices_post)
      @zord.receive!
    end
  end

  describe 'receive_object' do
    before do
      @zord = Postzord::Receiver::Private.new(bob, :person => alice.person, :object => @alices_post)
      @salmon = @zord.instance_variable_get(:@salmon)
    end

    it 'calls Notification.notify if object responds to notification_type' do
      cm = Comment.new
      allow(cm).to receive(:receive).and_return(cm)

      expect(Notification).to receive(:notify).with(bob, cm, alice.person)
      zord = Postzord::Receiver::Private.new(bob, :person => alice.person, :object => cm)
      zord.receive_object
    end

    it 'does not call Notification.notify if object does not respond to notification_type' do
      expect(Notification).not_to receive(:notify)
      @zord.receive_object
    end

    it 'calls receive on @object' do
      obj = expect(@zord.instance_variable_get(:@object)).to receive(:receive)
      @zord.receive_object
    end
  end
end

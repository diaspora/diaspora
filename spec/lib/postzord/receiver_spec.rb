#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require File.join(Rails.root, 'lib/postzord')
require File.join(Rails.root, 'lib/postzord/receiver')

describe Postzord::Receiver do

  before do
    @user = alice
    @user2 = bob
    @person2 = @user2.person

    aspect1 = @user.aspects.first
    aspect2 = @user2.aspects.first

    @original_post = @user2.build_post(:status_message, :message => "hey", :aspect_ids => [aspect2.id])
    @salmon_xml = @user2.salmon(@original_post).xml_for(@user.person)
  end

  describe '.initialize' do
    it 'valid for local' do
      Webfinger.should_not_receive(:new)
      Salmon::SalmonSlap.should_not_receive(:parse)

      zord = Postzord::Receiver.new(@user, :person => @person2, :object => @original_post)
      zord.instance_variable_get(:@user).should_not be_nil
      zord.instance_variable_get(:@sender).should_not be_nil
      zord.instance_variable_get(:@object).should_not be_nil
    end

    it 'valid for remote' do
      salmon_mock = mock()
      web_mock = mock()
      web_mock.should_receive(:fetch).and_return true
      salmon_mock.should_receive(:author_email).and_return(true)
      Salmon::SalmonSlap.should_receive(:parse).with(@salmon_xml, @user).and_return(salmon_mock)
      Webfinger.should_receive(:new).and_return(web_mock)

      zord = Postzord::Receiver.new(@user, :salmon_xml => @salmon_xml)
      zord.instance_variable_get(:@user).should_not be_nil
      zord.instance_variable_get(:@sender).should_not be_nil
      zord.instance_variable_get(:@salmon_xml).should_not be_nil
    end
  end

  describe '#perform' do
    before do
      @zord = Postzord::Receiver.new(@user, :salmon_xml => @salmon_xml)
      @salmon = @zord.instance_variable_get(:@salmon)
    end

    context 'returns nil' do
      it 'if the salmon author does not exist' do
        @zord.instance_variable_set(:@sender, nil)
        @zord.perform.should be_nil
      end

      it 'if the author does not match the signature' do
        @zord.instance_variable_set(:@sender, Factory(:person))
        @zord.perform.should be_nil
      end
    end

    context 'returns the sent object' do
      it 'returns the received object on success' do
        object = @zord.perform
        object.should respond_to(:to_diaspora_xml)
      end
    end

    it 'parses the salmon object' do
      Diaspora::Parser.should_receive(:from_xml).with(@salmon.parsed_data).and_return(@original_post)
      @zord.perform
    end
  end

  describe 'receive_object' do
    before do
      @zord = Postzord::Receiver.new(@user, :person => @person2, :object => @original_post)
      @salmon = @zord.instance_variable_get(:@salmon)
    end

    it 'calls Notification.notify if object responds to notification_type' do
      cm = Comment.new
      cm.stub!(:receive).and_return(cm)

      Notification.should_receive(:notify).with(@user, cm, @person2)
      zord = Postzord::Receiver.new(@user, :person => @person2, :object => cm)
      zord.receive_object
    end

    it 'does not call Notification.notify if object does not respond to notification_type' do
      Notification.should_not_receive(:notify)
      @zord.receive_object
    end

    it 'calls receive on @object' do
      obj = @zord.instance_variable_get(:@object).should_receive(:receive)
      @zord.receive_object
    end
  end
end

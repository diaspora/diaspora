#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

require File.join(Rails.root, 'lib/postzord')
require File.join(Rails.root, 'lib/postzord/receiver')

describe Postzord::Receiver do
  describe '.initialize' do
    it 'has @salmon_xml and an @user' do
      xml = "yeah"
      user = 'faa'
      salmon_mock = mock()
      web_mock = mock()
      web_mock.should_receive(:fetch).and_return true
      salmon_mock.should_receive(:author_email).and_return(true)
      Salmon::SalmonSlap.should_receive(:parse).with(xml, user).and_return(salmon_mock)
      Webfinger.should_receive(:new).and_return(web_mock)

      zord = Postzord::Receiver.new(user, xml)
      zord.instance_variable_get(:@user).should_not be_nil
      zord.instance_variable_get(:@salmon).should_not be_nil
      zord.instance_variable_get(:@salmon_author).should_not be_nil
    end
  end

  describe '#perform' do
    before do
      @user = make_user
      @user2 = make_user
      @person2 = @user2.person

      a = @user2.aspects.create(:name => "hey")
      @original_post = @user2.build_post(:status_message, :message => "hey", :aspect_ids => [a.id])

      salmon_xml = @user2.salmon(@original_post).xml_for(@user.person)
      @zord = Postzord::Receiver.new(@user, salmon_xml)
      @salmon = @zord.instance_variable_get(:@salmon)

    end

    context 'returns nil' do
      it 'if the salmon author does not exist' do
        @zord.instance_variable_set(:@salmon_author, nil)
        @zord.perform.should be_nil
      end

      it 'if the author does not match the signature' do
        @zord.instance_variable_set(:@salmon_author, Factory(:person))
        @zord.perform.should be_nil
      end

    end

    context 'returns the sent object' do
      it 'returns the received object on success' do
        pending
        object = @zord.perform
        object.should respond_to(:to_diaspora_xml)
      end
    end

    it 'parses the salmon object' do
      pending
      Diaspora::Parser.should_receive(:from_xml).with(@salmon.parsed_data)
      @zord.perform
    end
  end
end

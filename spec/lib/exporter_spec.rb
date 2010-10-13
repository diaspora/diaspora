#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, 'lib/diaspora/exporter')

describe Diaspora::Exporter do

  let!(:user1) { Factory(:user) }
  let!(:user2) { Factory(:user) }
  let!(:user3) { Factory(:user) }

  let(:aspect1) { user1.aspect(:name => "Work")   }
  let(:aspect2) { user2.aspect(:name => "Family") }
  let(:aspect3) { user3.aspect(:name => "Pivots") }

  let!(:status_message1) { user1.post(:status_message, :message => "One", :public => true, :to => aspect1.id) }
  let!(:status_message2) { user1.post(:status_message, :message => "Two", :public => true, :to => aspect1.id) }
  let!(:status_message3) { user2.post(:status_message, :message => "Three", :public => false, :to => aspect2.id) }

  let(:exported) { Diaspora::Exporter.new(Diaspora::Exporters::XML).execute(user1) }

  it 'should include a users posts' do
    exported.should include status_message1.message
    exported.should include status_message2.message
    exported.should_not include status_message3.message
  end

  it 'should include a users private key' do
    exported.should include user1.serialized_private_key
  end

  it 'should include post_ids' do 
    doc = Nokogiri::XML::parse(exported)
    doc.xpath('//aspects').to_s.should include status_message1.id.to_s

    doc.xpath('//aspects').to_s.should include status_message2.id.to_s
    doc.xpath('//posts').to_s.should include status_message1.id.to_s
  end

  it 'should include a list of users posts' do 
    doc = Nokogiri::XML::parse(exported)
    posts = doc.xpath('//posts').to_s
    posts.should include(status_message1.message)
  end

  it 'should serialize a users friends' do
    friend_users(user1, aspect1, user3, aspect3)
    doc = Nokogiri::XML::parse(exported) 
    doc.xpath('/export/people').to_s.should include user3.person.id.to_s
  end

  it 'should serialize only a users posts within his aspects' do
    message = Factory(:status_message, :message => "Shouldn't be here", :person => user3.person)
    aspect1.posts << message
    doc = Nokogiri::XML::parse(exported)
    doc.xpath('/export/aspects').to_s.should_not include message.message
  end
end

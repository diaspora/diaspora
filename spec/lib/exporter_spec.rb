#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.dirname(__FILE__) + '/../../lib/diaspora/exporter'

describe Diaspora::Exporter do

  let!(:user1) { Factory(:user) }
  let!(:user2) { Factory(:user) }

  let(:aspect1) { user1.aspect(:name => "Work")   }
  let(:aspect2) { user2.aspect(:name => "Family") }

  let!(:status_message1) { user1.post(:status_message, :message => "One", :public => true, :to => aspect1.id) }
  let!(:status_message2) { user1.post(:status_message, :message => "Two", :public => true, :to => aspect1.id) }
  let!(:status_message3) { user2.post(:status_message, :message => "Three", :public => false, :to => aspect2.id) }

  let!(:exported) { Diaspora::Exporter.new(Diaspora::Exporters::XML).execute(user1) }

  it 'should include a users posts' do
    exported.should include status_message1.to_xml.to_s
    exported.should include status_message2.to_xml.to_s
    exported.should_not include status_message3.to_xml.to_s
  end

  it 'should include a users private key' do
    exported.should include user1.serialized_private_key
  end

end


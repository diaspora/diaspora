#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.dirname(__FILE__) + '/../../lib/diaspora/ostatus_builder'

describe Diaspora::OstatusBuilder do

  let(:user) { Factory(:user) }
  let(:aspect) { user.aspect(:name => "Public People") }
  let!(:status_message1) { user.post(:status_message, :message => "One", :public => true, :to => aspect.id) }
  let!(:status_message2) { user.post(:status_message, :message => "Two", :public => true, :to => aspect.id) }
  let!(:status_message3) { user.post(:status_message, :message => "Three", :public => false, :to => aspect.id) }

  let!(:atom) { Diaspora::OstatusBuilder::build(user) }

  it 'should include a users posts' do
    atom.should include status_message1.message
    atom.should include status_message2.message
    atom.should_not include status_message3.message
  end

end


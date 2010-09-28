#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.dirname(__FILE__) + '/../../lib/diaspora/ostatus_builder'

describe Diaspora::OstatusBuilder do

  let(:user) { Factory(:user) }
  let(:aspect) { user.aspect(:name => "Public People") }
  let!(:status_message1) { user.post(:status_message, :message => "One", :to => aspect.id) }
  let!(:status_message2) { user.post(:status_message, :message => "Two", :to => aspect.id) }

  let!(:atom) { Diaspora::OstatusBuilder::build(user) }

end


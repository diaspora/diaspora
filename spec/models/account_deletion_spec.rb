#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe AccountDeletion do

  it 'gets initialized with diaspora_id' do
    AccountDeletion.new(:diaspora_id => alice.person.diaspora_handle).should be_true
  end

  
end

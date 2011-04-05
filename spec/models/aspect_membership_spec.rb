#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
require 'spec_helper'

describe AspectMembership do

  describe '#before_delete' do
    it 'calls disconnect' do
      pending
      alice.should_receive(:disconnect).with(alice.contact_for(bob))

      alice.aspects.create(:name => "two")
      alice.aspects.first.destroy
    end
  end

end

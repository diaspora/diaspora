#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
require 'spec_helper'

describe AspectMembership do

  describe '#before_destroy' do
    before do
      @aspect = alice.aspects.create(:name => "two")
      @contact = alice.contact_for(bob.person)

      @am = alice.aspects.where(:name => "generic").first.aspect_memberships.first
      @am.stub(:user).and_return(alice)
    end

    it 'calls disconnect if its the last aspect for the contact' do
      alice.should_receive(:disconnect).with(@contact)

      @am.destroy
    end

    it 'does not call disconnect if its not the last aspect for the contact' do
      alice.should_not_receive(:disconnect)

      alice.add_contact_to_aspect(@contact, @aspect)
      @am.destroy     
    end
  end

end

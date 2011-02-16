#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
require 'spec_helper'

describe AspectMembership do
  before do
    @user = alice
    @user2 = bob
    @aspect = @user.aspects.create(:name => 'Boozers')
    @contact = @user.contact_for(@user2.person)
  end

  it 'has an aspect' do
    am = AspectMembership.new(:aspect => @aspect)
    am.aspect.should == @aspect
  end

  it 'has a contact' do
    am = AspectMembership.new(:contact => @contact)
    am.contact.should == @contact 
  end

  context 'validations' do
    describe '#ensure_membership' do
      it 'does not destroy from the final aspect' do
        am = @contact.aspect_memberships.first
        am.destroy
        am.errors.should_not be_empty
      end
    end
  end
end

#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Invitation do
  let(:user)   {make_user}
  let(:aspect) {user.aspects.create(:name => "Invitees")}
  let(:user2)  {make_user}
  describe 'validations' do
    before do
      aspect
      @invitation = Invitation.new(:from => user, :to => user2, :into => aspect) 
    end
    it 'is valid' do
      @invitation.should be_valid
      @invitation.from.should == user
      @invitation.to.should   == user2
      @invitation.into.should == aspect
    end
    it 'is from a user' do
      @invitation.from = nil
      @invitation.should_not be_valid
    end
    it 'is to a user' do
      @invitation.to = nil
      @invitation.should_not be_valid
    end
    it 'is into an aspect' do
      @invitation.into = nil
      @invitation.should_not be_valid
    end
  end
end


#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require 'spec_helper'

describe GettingStartedHelper do
  before do
    @current_user = alice
  end

  def current_user
    @current_user
  end

  describe "#has_completed_getting_started?" do
    it 'returns true if the current user has completed getting started' do
      @current_user.getting_started = false
      @current_user.save
      has_completed_getting_started?.should be_true
    end

    it 'returns false if the current user has not completed getting started' do
      @current_user.getting_started = true
      @current_user.save
      has_completed_getting_started?.should be_false
    end
  end
end

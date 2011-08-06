#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
require 'spec_helper'

describe ProfilesHelper do
  before do
    @profile = Factory(:person).profile
  end

  describe '#field_filled_out?' do
    it 'returns false if not set' do
      field_filled_out?(@profile, :bio).should be_false
    end

    it 'returns true if field is set' do
      @profile.bio = "abc"
      field_filled_out?(@profile, :bio).should be_true
    end
  end

  describe '#profile_field_tag' do
    it 'returns' do
      profile_field_tag(@profile, :bio).should_not be_blank
    end
  end
end

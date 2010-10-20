#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Profile do
  describe 'validation' do
    describe "of first_name" do
      it "requires first name" do
        profile = Factory.build(:profile, :first_name => nil)
        profile.should_not be_valid
        profile.first_name = "Hortense"
        profile.should be_valid
      end
      it "requires non-empty first name" do
        profile = Factory.build(:profile, :first_name => "     ")
        profile.should_not be_valid
      end
      it "strips leading and trailing whitespace" do
        profile = Factory.build(:profile, :first_name => "     Shelly    ")
        profile.should be_valid
        profile.first_name.should == "Shelly"
      end
    end
    describe "of last_name" do
      it "requires a last name" do
        profile = Factory.build(:profile, :last_name => nil)
        profile.should_not be_valid
        profile.last_name = "Shankar"
        profile.should be_valid
      end
      it "requires non-empty last name" do
        profile = Factory.build(:profile, :last_name => "     ")
        profile.should_not be_valid
      end
      it "strips leading and trailing whitespace" do
        profile = Factory.build(:profile, :last_name => "     Ohba    ")
        profile.should be_valid
        profile.last_name.should == "Ohba"
      end
    end
  end
end

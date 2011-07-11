#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ApplicationHelper do
  before do
    @user = alice
    @person = Factory.create(:person)
  end

  describe "#person_image_link" do
    it "returns an empty string if person is nil" do
      person_image_link(nil).should == ""
    end
    it "returns a link containing the person's photo" do
      person_image_link(@person).should include(@person.profile.image_url)
    end
    it "returns a link to the person's profile" do
      person_image_link(@person).should include(person_path(@person))
    end
  end

  describe "#person_image_tag" do
    it "should not allow basic XSS/HTML" do
      @person.profile.first_name = "I'm <h1>Evil"
      @person.profile.last_name = "I'm <h1>Evil"
      person_image_tag(@person).should_not include("<h1>")
    end
  end

  describe '#person_link' do
    before do
    @person = Factory(:person)
    end

    it 'includes the name of the person if they have a first name' do
      person_link(@person).should include @person.profile.first_name
    end

    it 'uses diaspora handle if the person has no first or last name' do
      @person.profile.first_name = nil
      @person.profile.last_name = nil

      person_link(@person).should include @person.diaspora_handle
    end

    it 'uses diaspora handle if first name and first name are rails#blank?' do
      @person.profile.first_name = " "
      @person.profile.last_name = " "

      person_link(@person).should include @person.diaspora_handle
    end

    it "should not allow basic XSS/HTML" do
      @person.profile.first_name = "I'm <h1>Evil"
      @person.profile.last_name = "I'm <h1>Evil"
      person_link(@person).should_not include("<h1>")
    end
  end
end

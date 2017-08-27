# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe PeopleHelper, :type => :helper do
  before do
    @user = alice
    @person = FactoryGirl.create(:person)
  end

  describe "#birthday_format" do
    it "contains the birth year if available" do
      birthday = Date.new 2016, 3, 5
      expect(birthday_format(birthday)).to include "2016"
    end

    it "does not contain the birth year if placeholder year is used" do
      birthday = Date.new 1004, 3, 5
      expect(birthday_format(birthday)).not_to include "1004"
    end
  end

  describe "#person_image_link" do
    it "returns an empty string if person is nil" do
      expect(person_image_link(nil)).to eq("")
    end
    it "returns a link containing the person's photo" do
      expect(person_image_link(@person)).to include(@person.profile.image_url)
    end
    it "returns a link to the person's profile" do
      expect(person_image_link(@person)).to include(person_path(@person))
    end
  end

  describe "#person_image_tag" do
    it "returns an empty string if person is nil" do
      expect(person_image_tag(nil)).to eq("")
    end
    it "should not allow basic XSS/HTML" do
      @person.profile.first_name = "I'm <h1>Evil"
      @person.profile.last_name = "I'm <h1>Evil"
      expect(person_image_tag(@person)).not_to include("<h1>")
    end
  end

  describe '#person_link' do
    before do
      @person = FactoryGirl.create(:person)
    end

    it 'includes the name of the person if they have a first name' do
      expect(person_link(@person)).to include @person.profile.first_name
    end

    it 'uses diaspora handle if the person has no first or last name' do
      @person.profile.first_name = nil
      @person.profile.last_name = nil

      expect(person_link(@person)).to include @person.diaspora_handle
    end

    it 'uses diaspora handle if first name and first name are rails#blank?' do
      @person.profile.first_name = " "
      @person.profile.last_name = " "

      expect(person_link(@person)).to include @person.diaspora_handle
    end

    it "should not allow basic XSS/HTML" do
      @person.profile.first_name = "I'm <h1>Evil"
      @person.profile.last_name = "I'm <h1>Evil"
      expect(person_link(@person)).not_to include("<h1>")
    end

    it 'links by id for a local user' do
      expect(person_link(@user.person)).to include "href='#{person_path(@user.person)}'"
    end

    it "recognizes the 'display_name' option" do
      display_name = "string used as a name"
      expect(person_link(@person, display_name: display_name)).to match(%r{<a [^>]+>#{display_name}</a>})
    end
  end

  describe '#local_or_remote_person_path' do
    before do
      @user = FactoryGirl.create(:user)
    end

    it "links by id if there is a period in the user's username" do
      @user.username = "invalid.username"
      @user.person.diaspora_handle = "#{@user.username}@#{AppConfig.pod_uri.authority}"
      expect(@user.save(validate: false)).to eq(true)

      expect(local_or_remote_person_path(@user.person)).to eq(person_path(@user.person))
    end

    it 'links by username for a local user' do
      expect(local_or_remote_person_path(@user.person)).to eq(user_profile_path(:username => @user.username))
    end

    it 'links by id for a remote person' do
      expect(local_or_remote_person_path(@person)).to eq(person_path(@person))
    end
  end
end

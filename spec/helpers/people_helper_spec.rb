#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe PeopleHelper do
 before do
    @user = alice
    @person = FactoryGirl.create(:person)
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
      @person = FactoryGirl.create(:person)
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

  describe '#last_post_link' do
    before do
      @person = FactoryGirl.create(:person)
    end

    it "doesn't show a link, if the person has no posts" do
      last_post_link(@person).should be_blank
    end

    it "shows the link, if the person has at leas one post" do
      post = FactoryGirl.create(:status_message, :author => @person)
      last_post_link(@person).should include last_post_person_path(@person.to_param)
    end
  end

  describe "#person_href" do
    it "calls local_or_remote_person_path and passes through the options" do
      opts = {:absolute => true}

      self.should_receive(:local_or_remote_person_path).with(@person, opts).exactly(1).times

      person_href(@person, opts)
    end

    it "returns a href attribute" do
      person_href(@person).should include "href="
    end
  end

  describe '#local_or_remote_person_path' do
    before do
      @user = FactoryGirl.create(:user)
    end

    it "links by id if there is a period in the user's username" do
      @user.username = "invalid.username"
      @user.save(:validate => false).should == true
      person = @user.person
      person.diaspora_handle = "#{@user.username}@#{AppConfig[:pod_uri].authority}"
      person.save!

      local_or_remote_person_path(@user.person).should == person_path(@user.person)
    end

    it 'links by username for a local user' do
      local_or_remote_person_path(@user.person).should == user_profile_path(:username => @user.username)
    end

    it 'links by id for a remote person' do
      local_or_remote_person_path(@person).should == person_path(@person)
    end
  end
end


#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Person do

  before do
    @user = bob
    @person  = Factory.create(:person)
  end

  describe "delegating" do
    it "delegates last_name to the profile" do
      @person.last_name.should == @person.profile.last_name
      @person.profile.update_attributes(:last_name => "Heathers")
      @person.reload.last_name.should == "Heathers"
    end
  end

  describe "vaild url" do
    it 'should allow for https urls' do
      person = Factory.create(:person, :url => "https://example.com")
      person.should be_valid
    end

    it 'should always return the correct receive url' do
      person = Factory.create(:person, :url => "https://example.com/a/bit/messed/up")
      person.receive_url.should == "https://example.com/receive/users/#{person.guid}/"
    end

    it 'should allow ports in the url' do
      person = Factory.create(:person, :url => "https://example.com:3000/")
      person.url.should == "https://example.com:3000/"
    end
  end


  describe '#diaspora_handle' do
    context 'local people' do
      it 'uses the pod config url to set the diaspora_handle' do
        new_user = Factory.create(:user)
        new_user.person.diaspora_handle.should == new_user.username + "@" + AppConfig[:pod_uri].host
      end
    end

    context 'remote people' do
      it 'stores the diaspora_handle in the database' do
        @person.diaspora_handle.include?(AppConfig[:pod_uri].host).should be false
      end
    end

    describe 'validation' do
      it 'is unique' do
        person_two = Factory.build(:person, :diaspora_handle => @person.diaspora_handle)
        person_two.should_not be_valid
      end

      it 'is case insensitive' do
        person_two = Factory.build(:person, :diaspora_handle => @person.diaspora_handle.upcase)
        person_two.should_not be_valid
      end
    end
  end

  context '#name' do
    let!(:user) { Factory(:user) }
    let!(:person) { user.person }
    let!(:profile) { person.profile }

    context 'with first name' do
      it 'should return their name for name' do
        person.name.should match /#{profile.first_name}|#{profile.last_name}/
      end
    end

    context 'without first name' do
      it 'should display their diaspora handle' do
        person.profile.first_name = nil
        person.profile.last_name = nil
        person.save!
        person.name.should == person.diaspora_handle
      end
    end
  end

  describe 'xml' do
    before do
      @xml = @person.to_xml.to_s
    end

    it 'should serialize to xml' do
      @xml.include?("person").should == true
    end

    it 'should have a profile in its xml' do
      @xml.include?("first_name").should == true

    end
  end

  it '#owns? posts' do
    person_message = Factory.create(:status_message, :author => @person)
    person_two = Factory.create(:person)

    @person.owns?(person_message).should be true
    person_two.owns?(person_message).should be false
  end

  describe '#remove_all_traces' do
    before do
      @deleter = Factory(:person)
      @status = Factory.create(:status_message, :author => @deleter)
      @other_status = Factory.create(:status_message, :author => @person)
    end

    it "deletes all notifications from a person's actions" do
      note = Factory(:notification, :actors => [@deleter], :recipient => @user)
      @deleter.destroy
      Notification.where(:id => note.id).first.should be_nil
    end

    it "deletes all contacts pointing towards a person" do
      @user.activate_contact(@deleter, @user.aspects.first)
      @deleter.destroy
      @user.contact_for(@deleter).should be_nil
    end

    it "deletes all of a person's posts upon person deletion" do
      lambda {@deleter.destroy}.should change(Post, :count).by(-1)
    end

    it "deletes a person's profile" do
      lambda {
        @deleter.destroy
      }.should change(Profile, :count).by(-1)
    end

    it 'deletes all requests to a person' do
      alice.send_contact_request_to(eve.person, alice.aspects.first)
      Request.count.should == 1
      lambda {
        eve.person.destroy
      }.should change(Request, :count).by(-1)
    end

    it 'deletes all requests from a person' do
      Request.create(:sender_id => @deleter.id, :recipient_id => alice.person.id)
      Request.count.should == 1
      lambda {
        @deleter.destroy
      }.should change(Request, :count).by(-1)
    end

    it "deletes a person's comments on person deletion" do
      Factory.create(:comment, :author_id => @deleter.id, :diaspora_handle => @deleter.diaspora_handle, :text => "i love you",     :post => @other_status)
      Factory.create(:comment, :author_id => @person.id,:diaspora_handle => @person.diaspora_handle,  :text => "you are creepy", :post => @other_status)

      lambda {@deleter.destroy}.should change(Comment, :count).by(-1)
    end
  end

  describe "disconnecting" do
    before do
      @user2   = Factory(:user)
      @aspect  = @user.aspects.create(:name => "Dudes")
      @aspect2 = @user2.aspects.create(:name => "Abscence of Babes")
    end
    it 'should not delete an orphaned contact' do
      @user.activate_contact(@person, @aspect)

      lambda {@user.disconnect(@user.contact_for(@person))}.should_not change(Person, :count)
    end

    it 'should not delete an un-orphaned contact' do
      @user.activate_contact(@person, @aspect)
      @user2.activate_contact(@person, @aspect2)

      lambda {@user.disconnect(@user.contact_for(@person))}.should_not change(Person, :count)
    end
  end

  describe '.search' do
    before do
      Person.delete_all
      @user = Factory.create(:user_with_aspect)
      user_profile = @user.person.profile
      user_profile.first_name = "aiofj"
      user_profile.last_name = "asdji"
      user_profile.save

      @robert_grimm = Factory.create(:searchable_person)
      @eugene_weinstein = Factory.create(:searchable_person)
      @yevgeniy_dodis = Factory.create(:searchable_person)
      @casey_grippi = Factory.create(:searchable_person)

      @robert_grimm.profile.first_name = "Robert"
      @robert_grimm.profile.last_name  = "Grimm"
      @robert_grimm.profile.save
      @robert_grimm.reload

      @eugene_weinstein.profile.first_name = "Eugene"
      @eugene_weinstein.profile.last_name  = "Weinstein"
      @eugene_weinstein.profile.save
      @eugene_weinstein.reload

      @yevgeniy_dodis.profile.first_name = "Yevgeniy"
      @yevgeniy_dodis.profile.last_name  = "Dodis"
      @yevgeniy_dodis.profile.save
      @yevgeniy_dodis.reload

      @casey_grippi.profile.first_name = "Casey"
      @casey_grippi.profile.last_name  = "Grippi"
      @casey_grippi.profile.save
      @casey_grippi.reload
    end
    it 'is ordered by last name' do
      @robert_grimm.profile.first_name = "AAA"
      @robert_grimm.profile.save

      @eugene_weinstein.profile.first_name = "AAA"
      @eugene_weinstein.profile.save

      @yevgeniy_dodis.profile.first_name = "AAA"
      @yevgeniy_dodis.profile.save

      @casey_grippi.profile.first_name = "AAA"
      @casey_grippi.profile.save

      people = Person.search("AAA", @user)
      people.map{|p| p.name}.should == [@yevgeniy_dodis, @robert_grimm, @casey_grippi, @eugene_weinstein].map{|p|p.name}
    end

    it 'should return nothing on an empty query' do
      people = Person.search("", @user)
      people.empty?.should be true
    end

    it 'should return nothing on a two character query' do
      people = Person.search("in", @user)
      people.empty?.should be true
    end

    it 'should yield search results on partial names' do
      people = Person.search("Eug", @user)
      people.count.should == 1
      people.first.should == @eugene_weinstein

      people = Person.search("wEi", @user)
      people.count.should == 1
      people.first.should == @eugene_weinstein

      people = Person.search("gri", @user)
      people.count.should == 2
      people.first.should == @robert_grimm
      people.second.should == @casey_grippi
    end

    it 'gives results on full names' do
      people = Person.search("Casey Grippi", @user)
      people.count.should == 1
      people.first.should == @casey_grippi
    end

    it 'only displays searchable people' do
      invisible_person = Factory(:person, :profile => Factory.build(:profile,:searchable => false, :first_name => "johnson"))
      Person.search("johnson", @user).should_not include invisible_person
      Person.search("", @user).should_not include invisible_person
    end

    it 'searches on handles' do
      people = Person.search(@robert_grimm.diaspora_handle, @user)
      people.should == [@robert_grimm]
    end

    it "puts the searching user's contacts first" do
      @robert_grimm.profile.first_name = "AAA"
      @robert_grimm.profile.save

      @eugene_weinstein.profile.first_name = "AAA"
      @eugene_weinstein.profile.save

      @yevgeniy_dodis.profile.first_name = "AAA"
      @yevgeniy_dodis.profile.save

      @casey_grippi.profile.first_name = "AAA"
      @casey_grippi.profile.save

      @user.activate_contact(@casey_grippi, @user.aspects.first)

      people = Person.search("AAA", @user)
      people.map{|p| p.name}.should == [@casey_grippi, @yevgeniy_dodis, @robert_grimm, @eugene_weinstein].map{|p|p.name}
    end
    it "puts the searching user's incoming requests first" do
      requestor = Factory(:user_with_aspect)
      profile = requestor.person.profile
      profile.first_name = "AAA"
      profile.last_name = "Something"
      profile.save

      @robert_grimm.profile.first_name = "AAA"
      @robert_grimm.profile.save

      @eugene_weinstein.profile.first_name = "AAA"
      @eugene_weinstein.profile.save

      @yevgeniy_dodis.profile.first_name = "AAA"
      @yevgeniy_dodis.profile.save

      @casey_grippi.profile.first_name = "AAA"
      @casey_grippi.profile.save

      requestor.send_contact_request_to(@user.person, requestor.aspects.first)
      people = Person.search("AAA", @user)
      people.map{|p| p.name}.should == [requestor.person, @yevgeniy_dodis, @robert_grimm, @casey_grippi, @eugene_weinstein].map{|p|p.name}
    end
  end

  context 'people finders for webfinger' do
    let(:user) {Factory(:user)}
    let(:person) {Factory(:person)}

    describe '.by_account_identifier' do
      it 'should find a local users person' do
        p = Person.by_account_identifier(user.diaspora_handle)
        p.should == user.person
      end

      it 'should find remote users person' do
        p = Person.by_account_identifier(person.diaspora_handle)
        p.should == person
      end

      it 'should downcase and strip the diaspora_handle' do
        dh_upper = "    " + user.diaspora_handle.upcase + "   "
        Person.by_account_identifier(dh_upper).should == user.person
      end

      it "finds a local person with a mixed-case username" do
        user = Factory(:user, :username => "SaMaNtHa")
        person = Person.by_account_identifier(user.person.diaspora_handle)
        person.should == user.person
      end

      it "is case insensitive" do
        user1 = Factory(:user, :username => "SaMaNtHa")
        person = Person.by_account_identifier(user1.person.diaspora_handle.upcase)
        person.should == user1.person
      end

      it 'should only find people who are exact matches (1/2)' do
        user = Factory(:user, :username => "SaMaNtHa")
        person = Factory(:person, :diaspora_handle => "tomtom@tom.joindiaspora.com")
        user.person.diaspora_handle = "tom@tom.joindiaspora.com"
        user.person.save
        Person.by_account_identifier("tom@tom.joindiaspora.com").diaspora_handle.should == "tom@tom.joindiaspora.com"
      end

      it 'should only find people who are exact matches (2/2)' do
        person = Factory(:person, :diaspora_handle => "tomtom@tom.joindiaspora.com")
        person1 = Factory(:person, :diaspora_handle => "tom@tom.joindiaspora.comm")
        f = Person.by_account_identifier("tom@tom.joindiaspora.com")
        f.should be nil
      end


    end

    describe '.local_by_account_identifier' do
      it 'should find local users people' do
        p = Person.local_by_account_identifier(user.diaspora_handle)
        p.should == user.person
      end

      it 'should not find a remote person' do
        p = Person.local_by_account_identifier(@person.diaspora_handle)
        p.should be nil
      end

      it 'should call .by_account_identifier' do
        Person.should_receive(:by_account_identifier)
        Person.local_by_account_identifier(@person.diaspora_handle)
      end
    end
  end
end

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Person do

  before do
    @user = bob
    @person = FactoryGirl.create(:person)
  end

  it 'always has a profile' do
    Person.new.profile.should_not be_nil
  end

  it 'does not save automatically' do
    Person.new.persisted?.should be_false
    Person.new.profile.persisted?.should be_false
  end

  context 'scopes' do
    describe '.for_json' do
      it 'does not select public keys' do
        proc {
          Person.for_json.first.serialized_public_key
        }.should raise_error ActiveModel::MissingAttributeError
      end

      it 'selects distinct people' do
        aspect = bob.aspects.create(:name => 'hilarious people')
        aspect.contacts << bob.contact_for(eve.person)
        person_ids = Person.for_json.joins(:contacts => :aspect_memberships).
          where(:contacts => {:user_id => bob.id},
               :aspect_memberships => {:aspect_id => bob.aspect_ids}).map{|p| p.id}

        person_ids.uniq.should == person_ids
      end
    end

    describe '.local' do
      it 'returns only local people' do
        Person.local =~ [@person]
      end
    end

    describe '.remote' do
      it 'returns only local people' do
        Person.remote =~ [@user.person]
      end
    end

    describe '.find_person_from_guid_or_username' do
      it 'searchs for a person if id is passed' do
        Person.find_from_guid_or_username(:id => @person.guid).id.should == @person.id
      end

      it 'searchs a person from a user if username is passed' do
        Person.find_from_guid_or_username(:username => @user.username).id.should == @user.person.id
      end

      it 'throws active record not found exceptions if no person is found via id' do
        expect{
          Person.find_from_guid_or_username(:id => "2d13123")
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'throws active record not found exceptions if no person is found via username' do
        expect{
          Person.find_from_guid_or_username(:username => 'michael_jackson')
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe '.all_from_aspects' do
      it "pulls back the right people given all a user's aspects" do
        aspect_ids = bob.aspects.map(&:id)
        Person.all_from_aspects(aspect_ids, bob).map(&:id).should =~ bob.contacts.includes(:person).map{|c| c.person.id}
      end

      it "pulls back the right people given a subset of aspects" do
        aspect_ids = bob.aspects.first.id
        Person.all_from_aspects(aspect_ids, bob).map(&:id).should =~ bob.aspects.first.contacts.includes(:person).map{|c| c.person.id}
      end

      it "respects aspects given a user" do
        aspect_ids = alice.aspects.map(&:id)
        Person.all_from_aspects(aspect_ids, bob).map(&:id).should == []
      end
    end

    describe ".who_have_reshared a user's posts" do
      it 'pulls back users who reshared the status message of a user' do
        sm = FactoryGirl.create(:status_message, :author => alice.person, :public => true)
        reshare = FactoryGirl.create(:reshare, :root => sm)
        Person.who_have_reshared_a_users_posts(alice).should == [reshare.author]
      end
    end
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
      person = FactoryGirl.build(:person, :url => "https://example.com")
      person.should be_valid
    end

    it 'should always return the correct receive url' do
      person = FactoryGirl.build(:person, :url => "https://example.com/a/bit/messed/up")
      person.receive_url.should == "https://example.com/receive/users/#{person.guid}/"
    end

    it 'should allow ports in the url' do
      person = FactoryGirl.build(:person, :url => "https://example.com:3000/")
      person.url.should == "https://example.com:3000/"
    end
  end

  describe '#diaspora_handle' do
    context 'local people' do
      it 'uses the pod config url to set the diaspora_handle' do
        new_person = User.build(:username => "foo123", :email => "foo123@example.com", :password => "password", :password_confirmation => "password").person
        new_person.diaspora_handle.should == "foo123#{User.diaspora_id_host}"
      end

      it 'does not include www if it is set in app config' do
        old_url = AppConfig[:pod_url]
        AppConfig[:pod_url] = 'https://www.foobar.com/'
        new_person = User.build(:username => "foo123", :email => "foo123@example.com", :password => "password", :password_confirmation => "password").person
        new_person.diaspora_handle.should == "foo123@foobar.com"
        AppConfig[:pod_url] = old_url
      end
    end

    context 'remote people' do
      it 'stores the diaspora_handle in the database' do
        @person.diaspora_handle.include?(AppConfig[:pod_uri].host).should be false
      end
    end

    describe 'validation' do
      it 'is unique' do
        person_two = FactoryGirl.build(:person, :diaspora_handle => @person.diaspora_handle)
        person_two.should_not be_valid
      end

      it 'is case insensitive' do
        person_two = FactoryGirl.build(:person, :diaspora_handle => @person.diaspora_handle.upcase)
        person_two.should_not be_valid
      end
    end
  end

  context '.name_from_attrs' do
    before do
      @person = alice.person
      @profile = @person.profile
    end

    context 'with only first name' do
      it 'should return their first name for name' do
        Person.name_from_attrs(@profile.first_name, nil, @profile.diaspora_handle).should == @profile.first_name.strip
      end
    end

    context 'with only last name' do
      it 'should return their last name for name' do
        Person.name_from_attrs(nil, @profile.last_name, @profile.diaspora_handle).should == @profile.last_name.strip
      end
    end

    context 'with both first and last name' do
      it 'should return their composed name for name' do
        Person.name_from_attrs(@profile.first_name, @profile.last_name, @profile.diaspora_handle).should == "#{@profile.first_name.strip} #{@profile.last_name.strip}"
      end
    end

    context 'without first nor last name' do
      it 'should display their diaspora handle' do
        Person.name_from_attrs(nil, nil, @profile.diaspora_handle).should == @profile.diaspora_handle
      end
    end
  end

  describe '#name' do
    it 'calls Person.name_from_attrs' do
      profile = alice.person.profile
      Person.should_receive(:name_from_attrs).with(profile.first_name, profile.last_name, profile.person.diaspora_handle)
      alice.name
    end

    it "strips endline whitespace" do
      profile = alice.person.profile
      profile.first_name = "maxwell "
      profile.last_name = "salzberg "
      alice.name.should == "maxwell salzberg"
    end
  end

  describe 'XML' do
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
    person_message = FactoryGirl.create(:status_message, :author => @person)
    person_two = FactoryGirl.create(:person)

    @person.owns?(person_message).should be true
    person_two.owns?(person_message).should be false
  end

  describe "disconnecting" do
    before do
      @user2 = FactoryGirl.create(:user)
      @aspect = @user.aspects.create(:name => "Dudes")
      @aspect2 = @user2.aspects.create(:name => "Abscence of Babes")
    end
    it 'should not delete an orphaned contact' do
      @user.contacts.create(:person => @person, :aspects => [@aspect])

      lambda { @user.disconnect(@user.contact_for(@person)) }.should_not change(Person, :count)
    end

    it 'should not delete an un-orphaned contact' do
      @user.contacts.create(:person => @person, :aspects => [@aspect])
      @user2.contacts.create(:person => @person, :aspects => [@aspect2])

      lambda { @user.disconnect(@user.contact_for(@person)) }.should_not change(Person, :count)
    end
  end

  describe "#first_name" do
    it 'returns username if first_name is not present in profile' do
      alice.person.profile.update_attributes(:first_name => "")
      alice.person.first_name.should == alice.username
    end

    it 'returns first words in first_name if first_name is present' do
      alice.person.profile.update_attributes(:first_name => "First Mid Last")
      alice.person.first_name.should == "First Mid"
    end

    it 'returns first word in first_name if first_name is present' do
      alice.person.profile.update_attributes(:first_name => "Alice")
      alice.person.first_name.should == "Alice"
    end
  end

  describe '.search' do
    before do
      Person.delete_all
      @user = FactoryGirl.create(:user_with_aspect)
      user_profile = @user.person.profile
      user_profile.first_name = "aiofj"
      user_profile.last_name = "asdji"
      user_profile.save

      @robert_grimm = FactoryGirl.build(:searchable_person)
      @eugene_weinstein = FactoryGirl.build(:searchable_person)
      @yevgeniy_dodis = FactoryGirl.build(:searchable_person)
      @casey_grippi = FactoryGirl.build(:searchable_person)

      @robert_grimm.profile.first_name = "Robert"
      @robert_grimm.profile.last_name = "Grimm"
      @robert_grimm.profile.save
      @robert_grimm.reload

      @eugene_weinstein.profile.first_name = "Eugene"
      @eugene_weinstein.profile.last_name = "Weinstein"
      @eugene_weinstein.profile.save
      @eugene_weinstein.reload

      @yevgeniy_dodis.profile.first_name = "Yevgeniy"
      @yevgeniy_dodis.profile.last_name = "Dodis"
      @yevgeniy_dodis.profile.save
      @yevgeniy_dodis.reload

      @casey_grippi.profile.first_name = "Casey"
      @casey_grippi.profile.last_name = "Grippi"
      @casey_grippi.profile.save
      @casey_grippi.reload
    end
    it 'orders results by last name' do
      @robert_grimm.profile.first_name = "AAA"
      @robert_grimm.profile.save!

      @eugene_weinstein.profile.first_name = "AAA"
      @eugene_weinstein.profile.save!

      @yevgeniy_dodis.profile.first_name = "AAA"
      @yevgeniy_dodis.profile.save!

      @casey_grippi.profile.first_name = "AAA"
      @casey_grippi.profile.save!

      people = Person.search("AAA", @user)
      people.map { |p| p.name }.should == [@yevgeniy_dodis, @robert_grimm, @casey_grippi, @eugene_weinstein].map { |p| p.name }
    end

    it 'returns nothing on an empty query' do
      people = Person.search("", @user)
      people.should be_empty
    end

    it 'returns nothing on a one-character query' do
      people = Person.search("i", @user)
      people.should be_empty
    end

    it 'returns results for partial names' do
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

    it 'returns results for full names' do
      people = Person.search("Casey Grippi", @user)
      people.count.should == 1
      people.first.should == @casey_grippi
    end

    it 'only displays searchable people' do
      invisible_person = FactoryGirl.build(:person, :profile => FactoryGirl.build(:profile, :searchable => false, :first_name => "johnson"))
      Person.search("johnson", @user).should_not include invisible_person
      Person.search("", @user).should_not include invisible_person
    end

    it 'returns results for Diaspora handles' do
      people = Person.search(@robert_grimm.diaspora_handle, @user)
      people.should == [@robert_grimm]
    end

    it "puts the searching user's contacts first" do
      @robert_grimm.profile.first_name = "AAA"
      @robert_grimm.profile.save!

      @eugene_weinstein.profile.first_name = "AAA"
      @eugene_weinstein.profile.save!

      @yevgeniy_dodis.profile.first_name = "AAA"
      @yevgeniy_dodis.profile.save!

      @casey_grippi.profile.first_name = "AAA"
      @casey_grippi.profile.save!

      @user.contacts.create(:person => @casey_grippi, :aspects => [@user.aspects.first])

      people = Person.search("AAA", @user)
      people.map { |p| p.name }.should == [@casey_grippi, @yevgeniy_dodis, @robert_grimm, @eugene_weinstein].map { |p| p.name }
    end
  end

  context 'people finders for webfinger' do
    let(:user) { FactoryGirl.create(:user) }
    let(:person) { FactoryGirl.create(:person) }

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
        user = FactoryGirl.create(:user, :username => "SaMaNtHa")
        person = Person.by_account_identifier(user.person.diaspora_handle)
        person.should == user.person
      end

      it "is case insensitive" do
        user1 = FactoryGirl.create(:user, :username => "SaMaNtHa")
        person = Person.by_account_identifier(user1.person.diaspora_handle.upcase)
        person.should == user1.person
      end

      it 'should only find people who are exact matches (1/2)' do
        user = FactoryGirl.create(:user, :username => "SaMaNtHa")
        person = FactoryGirl.create(:person, :diaspora_handle => "tomtom@tom.joindiaspora.com")
        user.person.diaspora_handle = "tom@tom.joindiaspora.com"
        user.person.save
        Person.by_account_identifier("tom@tom.joindiaspora.com").diaspora_handle.should == "tom@tom.joindiaspora.com"
      end

      it 'should only find people who are exact matches (2/2)' do
        person = FactoryGirl.create(:person, :diaspora_handle => "tomtom@tom.joindiaspora.com")
        person1 = FactoryGirl.create(:person, :diaspora_handle => "tom@tom.joindiaspora.comm")
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
  describe '#has_photos?' do
    it 'returns false if the user has no photos' do
      alice.person.has_photos?.should be_false
    end

    it 'returns true if the user has photos' do
      alice.post(:photo, :user_file => uploaded_photo, :to => alice.aspects.first.id)

      alice.person.has_photos?.should be_true
    end
  end

  describe '#as_json' do
    it 'returns a hash representation of a person' do
      @person.as_json.should == {
        :id => @person.id,
        :guid => @person.guid,
        :name => @person.name,
        :avatar => @person.profile.image_url(:thumb_medium),
        :handle => @person.diaspora_handle,
        :url => Rails.application.routes.url_helpers.person_path(@person),
      }
    end
    it 'return tags if asked' do
      @person.as_json(:includes => "tags").
        should == @person.as_json.merge(:tags => @person.profile.tags.map { |t| "##{t.name}" })
    end
  end

  describe '.community_spotlight' do
    describe "when the pod owner hasn't set up any community spotlight members" do
      it 'returns people with the community spotlight role' do
        Role.add_spotlight(bob.person)
        Person.community_spotlight.should be_present
      end

      it "returns an empty array" do
        Person.community_spotlight.should == []
      end
    end
  end

  context 'updating urls' do
    before do
      @url = "http://new-url.com/"
    end

    describe '.url_batch_update' do
      it "calls #update_person_url given an array of users and a url" do
        people = [stub.as_null_object, stub.as_null_object, stub.as_null_object]
        people.each do |person|
          person.should_receive(:update_url).with(@url)
        end
        Person.url_batch_update(people, @url)
      end
    end

    describe '#update_url' do
      it "updates a given person's url" do
        expect {
          alice.person.update_url(@url)
        }.to change {
          alice.person.reload.url
        }.from(anything).to(@url)
      end
    end
  end

  describe '#lock_access!' do
    it 'sets the closed_account flag' do
      @person.lock_access!
      @person.reload.closed_account.should be_true
    end
  end

  describe "#clear_profile!!" do
    before do
      @person = FactoryGirl.build(:person)
    end

    it 'calls Profile#tombstone!' do
      @person.profile.should_receive(:tombstone!)
      @person.clear_profile!
    end
  end
end

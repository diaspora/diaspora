#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Person do

  before do
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
    person_message = Factory.create(:status_message, :person => @person)
    person_two =     Factory.create(:person)

    @person.owns?(person_message).should be true
    person_two.owns?(person_message).should be false
  end

  describe '#remove_all_traces' do
    before do
      @user = Factory(:user_with_aspect)
      @deleter = Factory(:person)
      @status = Factory.create(:status_message, :person => @deleter)
      @other_status = Factory.create(:status_message, :person => @person)
    end

    it "deletes all notifications from a person's actions" do
      note = Notification.create(:actor_id => @deleter.id, :recipient_id => @user.id)
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

    it "does not delete a person's comments on person deletion" do
      Factory.create(:comment, :person_id => @deleter.id, :diaspora_handle => @deleter.diaspora_handle, :text => "i love you",     :post => @other_status)
      Factory.create(:comment, :person_id => @person.id,:diaspora_handle => @person.diaspora_handle,  :text => "you are creepy", :post => @other_status)

      lambda {@deleter.destroy}.should_not change(Comment, :count)
    end
  end

  describe "disconnecting" do
    before do
      @user    = Factory(:user)
      @user2   = Factory(:user)
      @aspect  = @user.aspects.create(:name => "Dudes")
      @aspect2 = @user2.aspects.create(:name => "Abscence of Babes")
    end
    it 'should not delete an orphaned contact' do
      @user.activate_contact(@person, @aspect)

      lambda {@user.disconnect(@person)}.should_not change(Person, :count)
    end

    it 'should not delete an un-orphaned contact' do
      @user.activate_contact(@person, @aspect)
      @user2.activate_contact(@person, @aspect2)

      lambda {@user.disconnect(@person)}.should_not change(Person, :count)
    end
  end

  describe '.search' do
    before do
      Person.delete_all
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

    it 'should return nothing on an empty query' do
      people = Person.search("")
      people.empty?.should be true
    end

    it 'should yield search results on partial names' do
      people = Person.search("Eu")
      people.count.should == 1
      people.first.should == @eugene_weinstein

      people = Person.search("wEi")
      people.count.should == 1
      people.first.should == @eugene_weinstein

      people = Person.search("gri")
      people.count.should == 2
      people.first.should == @casey_grippi
      people.second.should == @robert_grimm
    end

    it 'should yield results on full names' do
      people = Person.search("Casey Grippi")
      people.count.should == 1
      people.first.should == @casey_grippi
    end

    it 'should only display searchable people' do
      invisible_person = Factory(:person, :profile => Factory(:profile,:searchable => false, :first_name => "johnson"))
      Person.search("johnson").should_not include invisible_person
      Person.search("").should_not include invisible_person
    end

    it 'should search on handles' do
      people = Person.search(@robert_grimm.diaspora_handle)
      people.count.should == 1
      people.first.should == @robert_grimm
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

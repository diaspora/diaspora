#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require Rails.root.join('lib', 'diaspora', 'exporter')

describe Diaspora::Exporter do

  before do
    @user1 =  alice
    @user2 =  FactoryGirl.create(:user)
    @user3 =  bob

    @user1.person.profile.first_name = "<script>"
    @user1.person.profile.gender = "<script>"
    @user1.person.profile.bio = "<script>"
    @user1.person.profile.location = "<script>"
    @user1.person.profile.save

    @aspect  =  @user1.aspects.first
    @aspect1 =  @user1.aspects.create(:name => "Work")
    @aspect2 =  @user2.aspects.create(:name => "Family")
    @aspect3 =  @user3.aspects.first
    @aspect.name = "<script>"
    @aspect.save

    @status_message1 =  @user1.post(:status_message, :text => "One", :public => true, :to => @aspect1.id)
    @status_message2 =  @user1.post(:status_message, :text => "Two", :public => true, :to => @aspect1.id)
    @status_message3 =  @user2.post(:status_message, :text => "Three", :public => false, :to => @aspect2.id)
    @status_message4 =  @user1.post(:status_message, :text => "<script>", :public => true, :to => @aspect2.id)
  end

  def exported
    Nokogiri::XML(Diaspora::Exporter.new(Diaspora::Exporters::XML).execute(@user1))
  end

  it 'escapes xml relevant characters' do
    expect(exported.to_s).to_not include "<script>"
  end

  context '<user/>' do
    let(:user_xml) { exported.xpath('//user').to_s }

    it 'includes a users private key' do
      expect(user_xml).to include @user1.serialized_private_key
    end

    it 'includes the profile as xml' do
      expect(user_xml).to include "<profile>"
    end
  end

  context '<aspects/>' do
    let(:aspects_xml) { exported.xpath('//aspects').to_s }

    it 'includes the post_ids' do
      expect(aspects_xml).to include @status_message1.id.to_s
      expect(aspects_xml).to include @status_message2.id.to_s
    end
  end

  context '<contacts/>' do

    before do
      @aspect.name = "Safe"
      @aspect.save
      @user1.add_contact_to_aspect(@user1.contact_for(@user3.person), @aspect1)
      @user1.reload
    end

    let(:contacts_xml) {exported.xpath('//contacts').to_s}
    it "includes a person's guid" do
      expect(contacts_xml).to include @user3.person.guid
    end

    it "includes the names of all aspects they are in" do
      #contact specific xml needs to be tested
      expect(@user1.contacts.find_by_person_id(@user3.person.id).aspects.count).to be > 0
      @user1.contacts.find_by_person_id(@user3.person.id).aspects.each { |aspect|
        expect(contacts_xml).to include aspect.name
      }
    end
  end

  context '<people/>' do
    let(:people_xml) {exported.xpath('//people').to_s}

    it 'includes their guid' do
      expect(people_xml).to include @user3.person.guid
    end

    it 'includes their profile' do
      expect(people_xml).to include @user3.person.profile.first_name
      expect(people_xml).to include @user3.person.profile.last_name
    end

    it 'includes their public key' do
      expect(people_xml).to include @user3.person.exported_key
    end

    it 'includes their diaspora handle' do
      expect(people_xml).to include @user3.person.diaspora_handle
    end
  end

  context '<posts>' do
    let(:posts_xml) {exported.xpath('//posts').to_s}
    it "includes many posts' xml" do
      expect(posts_xml).to include @status_message1.text
      expect(posts_xml).to include @status_message2.text
      expect(posts_xml).not_to include @status_message3.text
    end

    it "includes the post's created at time" do
      @status_message1.update_attribute(:created_at, Time.now - 1.day) # make sure they have different created at times

      doc = Nokogiri::XML::parse(posts_xml)
      created_at_text = doc.xpath('//posts/status_message').detect do |status|
        status.to_s.include?(@status_message1.guid)
      end.xpath('created_at').text

      expect(Time.zone.parse(created_at_text).to_i).to eq(@status_message1.created_at.to_i)
    end
  end
end

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require Rails.root.join('lib', 'diaspora', 'exporter')

describe Diaspora::Exporter do

  before do
    @user1 =  alice

    @user1.person.profile.first_name = "<script>"
    @user1.person.profile.gender = "<script>"
    @user1.person.profile.bio = "<script>"
    @user1.person.profile.location = "<script>"
    @user1.person.profile.save

    @aspect  =  @user1.aspects.first
    @aspect1 =  @user1.aspects.create(:name => "Work", :contacts_visible => false)
    @aspect.name = "<script>"
    @aspect.save
  end

  context "json" do

    def json
      @json ||= JSON.parse Diaspora::Exporter.new(@user1).execute
    end

    it { matches :version, to: '1.0' }
    it { matches :user, :name }
    it { matches :user, :email }
    it { matches :user, :username }
    it { matches :user, :language }
    it { matches :user, :disable_mail }
    it { matches :user, :show_community_spotlight_in_stream }
    it { matches :user, :auto_follow_back }
    it { matches :user, :auto_follow_back_aspect }
    it { matches :user, :strip_exif }

    it { matches :user, :profile, :first_name,      root: @user1.person.profile }
    it { matches :user, :profile, :last_name,       root: @user1.person.profile }
    it { matches :user, :profile, :gender,          root: @user1.person.profile }
    it { matches :user, :profile, :bio,             root: @user1.person.profile }
    it { matches :user, :profile, :location,        root: @user1.person.profile }
    it { matches :user, :profile, :image_url,       root: @user1.person.profile }
    it { matches :user, :profile, :diaspora_handle, root: @user1.person.profile }
    it { matches :user, :profile, :searchable,      root: @user1.person.profile }
    it { matches :user, :profile, :nsfw,            root: @user1.person.profile }

    it { matches_relation :aspects,  :name,
                                     :contacts_visible,
                                     :chat_enabled }

    it { matches_relation :contacts, :sharing,
                                     :receiving,
                                     :person_guid,
                                     :person_name,
                                     :person_first_name,
                                     :person_diaspora_handle }

    private

    def matches(*fields, to: nil, root: @user1)
      expected = to || root.send(fields.last)
      expect(recurse_field(json, fields)).to eq expected
    end

    def matches_relation(relation, *fields, to: nil, root: @user1)
      array = json['user'][to || relation.to_s]
      fields.each do |field|
        expected = root.send(relation).map(&:"#{field}")
        expect(array.map { |f| f[field.to_s] }).to eq expected
      end
    end

    def recurse_field(json, fields)
      if fields.any?
        recurse_field json[fields.shift.to_s], fields
      else
        json
      end
    end

  end
end

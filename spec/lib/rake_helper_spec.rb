#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require File.join(Rails.root, 'lib/rake_helpers.rb')
include RakeHelpers
describe RakeHelpers do
  before do
    @csv = File.join(Rails.root, 'spec/fixtures/test.csv')
  end
  describe '#process_emails' do
    before do
      Devise.mailer.deliveries = []
    end
    it 'should send emails to each backer' do
      Invitation.should_receive(:create_invitee).exactly(3).times
      process_emails(@csv, 100, 1, 10, false)
    end

    it 'should not send the email to the same email twice' do
      process_emails(@csv, 100, 1, 10, false)

      Devise.mailer.deliveries.count.should == 3
      process_emails(@csv, 100, 1, 10, false)

      Devise.mailer.deliveries.count.should == 3
    end

    it 'should make a user with 10 invites' do
      User.count.should == 0

      process_emails(@csv, 1, 1, 10, false)
      
      User.count.should == 1
      User.first.invites.should == 10
    end
  end

  describe '#fix_spaces' do

    before do
      Factory(:person)
      5.times do |number|
        f = Factory.create(:user)
        f.person.diaspora_handle = "#{f.username}  #{AppConfig[:pod_uri].host}"
        f.person.url = AppConfig[:pod_url]
        f.person.save(:validate => false)
      end
       p = Factory(:person)
       p.diaspora_handle = "bubblegoose  @#{AppConfig[:pod_uri].host}"
       p.url = AppConfig[:pod_url]
       p.save(:validate => false)
    end

    it 'should fix diaspora handles' do

    
      RakeHelpers::fix_diaspora_handle_spaces(false)

      Person.all.all?{|x| !x.diaspora_handle.include?(" ")}.should == true
    end
    
    it 'should delete broken space people with no users' do
      expect{
        RakeHelpers::fix_diaspora_handle_spaces(false)
      }.to change(Person, :count).by(-1)
    end
  end


  describe '#fix_periods_in_username' do
    it 'should update a users username, his persons diaspora hande, and posts' do
      billy = Factory.create(:user)
      billy.username = "ma.x"
      billy.person.diaspora_handle = "ma.x@#{AppConfig[:pod_uri].host}"
      billy.person.save(:validate => false)
      billy.save(:validate => false)

      aspect = billy.aspects.create :name => "foo"
      billy.post :status_message, :message => "hi mom", :to => aspect.id

      RakeHelpers::fix_periods_in_username(false)

      new_d_handle = "max@#{AppConfig[:pod_uri].host}"

      User.first.username.should == 'max'
      User.first.person.diaspora_handle.should == new_d_handle
      User.first.my_posts.all.all?{|x| x.diaspora_handle == new_d_handle}.should == true
    end
  end
end


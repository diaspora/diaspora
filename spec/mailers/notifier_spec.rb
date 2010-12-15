
require 'spec_helper'

describe Notifier do

  let!(:user) {make_user}
  let!(:person) {Factory.create :person}

  before do
    Notifier.deliveries = []
  end
  describe '.administrative' do
    it 'mails a user' do
      mails = Notifier.admin("Welcome to bureaucracy!", [user])
      mails.length.should == 1
      mail = Notifier.deliveries.first
      mail.to.should == [user.email]
      mail.body.encoded.should match /Welcome to bureaucracy!/
      mail.body.encoded.should match /#{user.username}/
    end
    it 'mails a bunch of users' do
      users = []
      5.times do 
        users << make_user
      end
      Notifier.admin("Welcome to bureaucracy!", users)
      mails = Notifier.deliveries
      mails.length.should == 5
      mails.each{|mail|
        this_user = users.detect{|u| mail.to == [u.email]}
        mail.body.encoded.should match /Welcome to bureaucracy!/
        mail.body.encoded.should match /#{this_user.username}/
      }
    end
  end

  describe '#single_admin' do
    it 'mails a user' do
      mail = Notifier.single_admin("Welcome to bureaucracy!", user)
      mail.to.should == [user.email]
      mail.body.encoded.should match /Welcome to bureaucracy!/
      mail.body.encoded.should match /#{user.username}/
    end
  end

  describe "#new_request" do
    let!(:request_mail) {Notifier.new_request(user.id, person.id)}
    it 'goes to the right person' do
      request_mail.to.should == [user.email]
    end

    it 'has the receivers name in the body' do
      request_mail.body.encoded.include?(user.person.profile.first_name).should be true
    end


    it 'has the name of person sending the request' do
      request_mail.body.encoded.include?(person.name).should be true
    end

    it 'has the css' do
      request_mail.body.encoded.include?("<style type='text/css'>")
    end
  end

  describe "#request_accepted" do
    let!(:request_accepted_mail) {Notifier.request_accepted(user.id, person.id)}
    it 'goes to the right person' do
      request_accepted_mail.to.should == [user.email]
    end

    it 'has the receivers name in the body' do
      request_accepted_mail.body.encoded.include?(user.person.profile.first_name).should be true
    end

    it 'has the name of person sending the request' do
      request_accepted_mail.body.encoded.include?(person.name).should be true
    end
  end
end

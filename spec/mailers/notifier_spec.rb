
require 'spec_helper'

describe Notifier do

  let!(:user) {make_user}
  let!(:aspect) {user.aspects.create(:name => "science")}
  let!(:person) {Factory.create :person}
  let!(:request_mail) {Notifier.new_request(user, person)}
  let!(:request_accepted_mail) {Notifier.request_accepted(user, person, aspect)}


  describe "#new_request" do
    it 'goes to the right person' do
      request_mail.to.should == [user.email]
    end

    it 'has the receivers name in the body' do
      request_mail.body.encoded.include?(user.person.profile.first_name).should be true
    end


    it 'has the name of person sending the request' do
      request_mail.body.encoded.include?(person.real_name).should be true
    end
  end

  describe "#request_accpeted" do
    it 'goes to the right person' do
      request_accepted_mail.to.should == [user.email]
    end

    it 'has the receivers name in the body' do
      request_accepted_mail.body.encoded.include?(user.person.profile.first_name).should be true
    end


    it 'has the name of person sending the request' do
      request_accepted_mail.body.encoded.include?(person.real_name).should be true
    end

    it 'has the name of the aspect in the body' do
      request_accepted_mail.body.encoded.include?(aspect.name).should be true
    end
  end
end

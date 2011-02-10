
require 'spec_helper'

describe Notifier do
  let!(:user) {alice}
  let!(:user2) {eve}

  let!(:aspect) {user.aspects.create(:name => "win")}
  let!(:aspect2) {user2.aspects.create(:name => "win")}
  let!(:person) {Factory.create :person}

  before do
    Notifier.deliveries = []
  end
  describe '.administrative' do
    it 'mails a user' do
      mails = Notifier.admin("Welcome to bureaucracy!", [user])
      mails.length.should == 1
      mail = mails.first
      mail.to.should == [user.email]
      mail.body.encoded.should match /Welcome to bureaucracy!/
      mail.body.encoded.should match /#{user.username}/
    end
    it 'mails a bunch of users' do
      users = []
      5.times do
        users << Factory.create(:user)
      end
      mails = Notifier.admin("Welcome to bureaucracy!", users)
      mails.length.should == 5
      mails.each{|mail|
        this_user = users.detect{|u| mail.to == [u.email]}
        mail.body.encoded.should match /Welcome to bureaucracy!/
        mail.body.encoded.should match /#{this_user.username}/
      }
    end
  end

  describe '.single_admin' do
    it 'mails a user' do
      mail = Notifier.single_admin("Welcome to bureaucracy!", user)
      mail.to.should == [user.email]
      mail.body.encoded.should match /Welcome to bureaucracy!/
      mail.body.encoded.should match /#{user.username}/
    end
  end

  describe ".new_request" do
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

  describe ".request_accepted" do
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


  describe ".mentioned" do
    before do
      @user = alice
      @sm =  Factory(:status_message)
      @m  = Mention.create(:person => @user.person, :post=> @sm)

      @mail = Notifier.mentioned(@user.id, @sm.person.id, @m.id)
    end
    it 'goes to the right person' do
      @mail.to.should == [@user.email]
    end

    it 'has the receivers name in the body' do
      @mail.body.encoded.include?(@user.person.profile.first_name).should be true
    end

    it 'has the name of person mentioning in the body' do
      @mail.body.encoded.include?(@sm.person.name).should be true
    end

    it 'has the post text in the body' do
      @mail.body.encoded.should include(@sm.message)
    end

    it 'should not include translation missing' do
      @mail.body.encoded.should_not include("missing")
    end
  end


  context "comments" do
    let!(:connect) { connect_users(user, aspect, user2, aspect2)}
    let!(:sm) {user.post(:status_message, :message => "Sunny outside", :to => :all)}
    let!(:comment) { user2.comment("Totally is", :on => sm )}
    describe ".comment_on_post" do

      let!(:comment_mail) {Notifier.comment_on_post(user.id, person.id, comment.id).deliver}

      it 'goes to the right person' do
        comment_mail.to.should == [user.email]
      end

      it 'has the receivers name in the body' do
        comment_mail.body.encoded.include?(user.person.profile.first_name).should be true
      end

      it 'has the name of person commenting' do
        comment_mail.body.encoded.include?(person.name).should be true
      end

      it 'has the post link in the body' do
        comment_mail.body.encoded.include?("#{comment.post.id.to_s}").should be true
      end

    end
    describe ".also commented" do

      let!(:comment_mail) {Notifier.also_commented(user.id, person.id, comment.id)}

      it 'goes to the right person' do
        comment_mail.to.should == [user.email]
      end

      it 'has the receivers name in the body' do
        comment_mail.body.encoded.include?(user.person.profile.first_name).should be true
      end

      it 'has the name of person commenting' do
        comment_mail.body.encoded.include?(person.name).should be true
      end

      it 'has the post link in the body' do
        comment_mail.body.encoded.include?("#{comment.post.id.to_s}").should be true
      end

    end

  end
end

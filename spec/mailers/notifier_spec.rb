
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

    it 'has the layout' do
      
      mail = Notifier.single_admin("Welcome to bureaucracy!", user)
      mail.body.encoded.should match /manage your email settings/
    end
  end

  describe ".started_sharing" do
    let!(:request_mail) {Notifier.started_sharing(user.id, person.id)}
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

  describe ".mentioned" do
    before do
      @user = alice
      @sm =  Factory(:status_message)
      @m  = Mention.create(:person => @user.person, :post=> @sm)

      @mail = Notifier.mentioned(@user.id, @sm.author.id, @m.id)
    end
    it 'goes to the right person' do
      @mail.to.should == [@user.email]
    end

    it 'has the receivers name in the body' do
      @mail.body.encoded.include?(@user.person.profile.first_name).should be_true
    end

    it 'has the name of person mentioning in the body' do
      @mail.body.encoded.include?(@sm.author.name).should be_true
    end

    it 'has the post text in the body' do
      @mail.body.encoded.should include(@sm.text)
    end

    it 'should not include translation missing' do
      @mail.body.encoded.should_not include("missing")
    end
  end

  describe ".liked" do
    before do
      @sm = Factory(:status_message, :author => alice.person)
      @like = @sm.likes.create(:author => bob.person)
      @mail = Notifier.liked(alice.id, @like.author.id, @like.id)
    end

    it 'goes to the right person' do
      @mail.to.should == [alice.email]
    end

    it 'has the receivers name in the body' do
      @mail.body.encoded.include?(alice.person.profile.first_name).should be true
    end

    it 'has the name of person liking in the body' do
      @mail.body.encoded.include?(@like.author.name).should be_true
    end

    it 'should not include translation missing' do
      @mail.body.encoded.should_not include("missing")
    end
  end

  describe ".private_message" do
    before do
      @user2 = bob
      @participant_ids = @user2.contacts.map{|c| c.person.id} + [ @user2.person.id]

      @create_hash = { :author => @user2.person, :participant_ids => @participant_ids ,
                       :subject => "cool stuff", :text => 'hey'}

      @cnv = Conversation.create(@create_hash)

      @mail = Notifier.private_message(user.id, @cnv.author.id, @cnv.messages.first.id)
    end
    it 'goes to the right person' do
      @mail.to.should == [user.email]
    end

    it 'has the recipients in the body' do
      @mail.body.encoded.include?(user.person.first_name).should be true
    end

    it 'has the name of the sender in the body' do
      @mail.body.encoded.include?(@cnv.author.name).should be true
    end

    it 'has the conversation subject in the body' do
      @mail.body.encoded.should include(@cnv.subject)
    end

    it 'has the post text in the body' do
      @mail.body.encoded.should include(@cnv.messages.first.text)
    end

    it 'should not include translation missing' do
      @mail.body.encoded.should_not include("missing")
    end
  end

  context "comments" do
    let!(:connect) { connect_users(user, aspect, user2, aspect2)}
    let!(:sm) {user.post(:status_message, :text => "Sunny outside", :to => :all)}
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

    describe ".confirm_email" do
      before do
        user.update_attribute(:unconfirmed_email, "my@newemail.com")
      end

      let!(:confirm_email) { Notifier.confirm_email(user.id) }
      
      it 'goes to the right person' do
        confirm_email.to.should == [user.unconfirmed_email]
      end

      it 'has the unconfirmed emil in the subject' do
        confirm_email.subject.should include(user.unconfirmed_email)
      end

      it 'has the unconfirmed emil in the body' do
        confirm_email.body.encoded.should include(user.unconfirmed_email)
      end

      it 'has the receivers name in the body' do
        confirm_email.body.encoded.should include(user.person.profile.first_name)
      end

      it 'has the activation link in the body' do
        confirm_email.body.encoded.should include(confirm_email_url(:token => user.confirm_email_token))
      end

    end
  end
end

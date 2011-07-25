require 'spec_helper'

describe Notifier do
  include ActionView::Helpers::TextHelper

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
      mail.body.encoded.should match /change your notification settings/
    end
  end

  describe ".started_sharing" do
    let!(:request_mail) {Notifier.started_sharing(user.id, person.id)}
    it 'goes to the right person' do
      request_mail.to.should == [user.email]
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
      @sm = Factory(:status_message)
      @m = Mention.create(:person => @user.person, :post=> @sm)

      @mail = Notifier.mentioned(@user.id, @sm.author.id, @m.id)
    end

    it 'TO: goes to the right person' do
      @mail.to.should == [@user.email]
    end

    it 'SUBJECT: has the name of person mentioning in the subject' do
      @mail.subject.should include(@sm.author.name)
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
      @like = @sm.likes.create!(:author => bob.person)
      @mail = Notifier.liked(alice.id, @like.author.id, @like.id)
    end

    it 'TO: goes to the right person' do
      @mail.to.should == [alice.email]
    end

    it 'BODY: contains the truncated original post' do
      @mail.body.encoded.should include(@sm.formatted_message)
    end

    it 'BODY: contains the name of person liking' do
      @mail.body.encoded.should include(@like.author.name)
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

    it 'TO: goes to the right person' do
      @mail.to.should == [user.email]
    end

    it "FROM: contains the sender's name" do
      pending
      @mail.from.should == "\"#{person.name} (Diaspora)\" <#{AppConfig[:smtp_sender_address]}>"
    end

    it 'SUBJECT: has a snippet of the post contents' do
      @mail.subject.should == @cnv.subject
    end

    it 'SUBJECT: has "Re:" if not the first message in a conversation' do
      @cnv.messages << Message.new(:text => 'yo', :author => eve.person)
      @mail = Notifier.private_message(user.id, @cnv.author.id, @cnv.messages.last.id)

      @mail.subject.should == "Re: #{@cnv.subject}"
    end

    it 'BODY: contains the message text' do
      @mail.body.encoded.should include(@cnv.messages.first.text)
    end

    it 'should not include translation missing' do
      @mail.body.encoded.should_not include("missing")
    end
  end

  context "comments" do
    let!(:connect) { connect_users(user, aspect, user2, aspect2)}
    let!(:sm) {user.post(:status_message, :text => "It's really sunny outside today, and this is a super long status message!  #notreally", :to => :all)}
    let!(:comment) { user2.comment("Totally is", :post => sm )}

    describe ".comment_on_post" do
      let!(:comment_mail) {Notifier.comment_on_post(user.id, person.id, comment.id).deliver}

      it 'TO: goes to the right person' do
        comment_mail.to.should == [user.email]
      end

      it "FROM: contains the sender's name" do
        pending
        comment_mail.from.should == "\"#{person.name} (Diaspora)\" <#{AppConfig[:smtp_sender_address]}>"
      end

      it 'SUBJECT: has a snippet of the post contents' do
        comment_mail.subject.should == "Re: #{truncate(sm.text, :length => 70)}"
      end

      context 'BODY' do
        it "contains the comment" do
          comment_mail.body.encoded.should include(comment.text)
        end

        it "contains the original post's link" do
          comment_mail.body.encoded.include?("#{comment.post.id.to_s}").should be true
        end
      end
    end

    describe ".also_commented" do
      let!(:comment_mail) {Notifier.also_commented(user.id, person.id, comment.id)}

      it 'TO: goes to the right person' do
        comment_mail.to.should == [user.email]
      end

      it 'FROM: has the name of person commenting as the sender' do
        pending
        comment_mail.from.should == "\"#{person.name} (Diaspora)\" <#{AppConfig[:smtp_sender_address]}>"
      end

      it 'SUBJECT: has a snippet of the post contents' do
        comment_mail.subject.should == "Re: #{truncate(sm.text, :length => 70)}"
      end

      context 'BODY' do
        it "contains the comment" do
          comment_mail.body.encoded.should include(comment.text)
        end

        it "contains the original post's link" do
          comment_mail.body.encoded.include?("#{comment.post.id.to_s}").should be true
        end
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

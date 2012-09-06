require 'spec_helper'

describe Notifier do
  include ActionView::Helpers::TextHelper

  let(:person) { FactoryGirl.create(:person) }

  before do
    Notifier.deliveries = []
  end

  describe '.administrative' do
    it 'mails a user' do
      mails = Notifier.admin("Welcome to bureaucracy!", [bob])
      mails.length.should == 1
      mail = mails.first
      mail.to.should == [bob.email]
      mail.body.encoded.should match /Welcome to bureaucracy!/
      mail.body.encoded.should match /#{bob.username}/
    end

    context 'mails a bunch of users' do
      before do
        @users = []
        5.times do
          @users << FactoryGirl.create(:user)
        end
      end
      it 'has a body' do
        mails = Notifier.admin("Welcome to bureaucracy!", @users)
        mails.length.should == 5
        mails.each{|mail|
          this_user = @users.detect{|u| mail.to == [u.email]}
          mail.body.encoded.should match /Welcome to bureaucracy!/
          mail.body.encoded.should match /#{this_user.username}/
        }
      end

      it "has attachments" do
        mails = Notifier.admin("Welcome to bureaucracy!", @users, :attachments => [{:name => "retention stats", :file => "here is some file content"}])
        mails.length.should == 5
        mails.each{|mail|
          mail.attachments.count.should == 1
        }
      end
    end
  end

  describe '.single_admin' do
    it 'mails a user' do
      mail = Notifier.single_admin("Welcome to bureaucracy!", bob)
      mail.to.should == [bob.email]
      mail.body.encoded.should match /Welcome to bureaucracy!/
      mail.body.encoded.should match /#{bob.username}/
    end

    it 'has the layout' do
      mail = Notifier.single_admin("Welcome to bureaucracy!", bob)
      mail.body.encoded.should match /change your notification settings/
    end

    it 'has an optional attachment' do
      mail = Notifier.single_admin("Welcome to bureaucracy!", bob, :attachments => [{:name => "retention stats", :file => "here is some file content"}])
      mail.attachments.length.should == 1
    end
  end

  describe ".started_sharing" do
    let!(:request_mail) { Notifier.started_sharing(bob.id, person.id) }

    it 'goes to the right person' do
      request_mail.to.should == [bob.email]
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
      @sm = FactoryGirl.create(:status_message)
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

    it 'should not include translation fallback' do
      @mail.body.encoded.should_not include(I18n.translate 'notifier.a_post_you_shared')
    end
  end

  describe ".liked" do
    before do
      @sm = FactoryGirl.create(:status_message, :author => alice.person)
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

    it 'should not include translation fallback' do
      @mail.body.encoded.should_not include(I18n.translate 'notifier.a_post_you_shared')
    end

    it 'can handle a reshare' do
      reshare = FactoryGirl.create(:reshare)
      like = reshare.likes.create!(:author => bob.person)
      mail = Notifier.liked(alice.id, like.author.id, like.id)
    end

    it 'can handle a activity streams photo' do
      as_photo = FactoryGirl.create(:activity_streams_photo)
      like = as_photo.likes.create!(:author => bob.person)
      mail = Notifier.liked(alice.id, like.author.id, like.id)
    end
  end

  describe ".reshared" do
    before do
      @sm = FactoryGirl.create(:status_message, :author => alice.person, :public => true)
      @reshare = FactoryGirl.create(:reshare, :root => @sm, :author => bob.person)
      @mail = Notifier.reshared(alice.id, @reshare.author.id, @reshare.id)
    end

    it 'TO: goes to the right person' do
      @mail.to.should == [alice.email]
    end

    it 'BODY: contains the truncated original post' do
      @mail.body.encoded.should include(@sm.formatted_message)
    end

    it 'BODY: contains the name of person liking' do
      @mail.body.encoded.should include(@reshare.author.name)
    end

    it 'should not include translation fallback' do
      @mail.body.encoded.should_not include(I18n.translate 'notifier.a_post_you_shared')
    end
  end


  describe ".private_message" do
    before do
      @user2 = bob
      @participant_ids = @user2.contacts.map{|c| c.person.id} + [ @user2.person.id]

      @create_hash = {
        :author => @user2.person,
        :participant_ids => @participant_ids,
        :subject => "cool stuff",
        :messages_attributes => [ {:author => @user2.person, :text => 'hey'} ]
      }

      @cnv = Conversation.create(@create_hash)

      @mail = Notifier.private_message(bob.id, @cnv.author.id, @cnv.messages.first.id)
    end

    it 'TO: goes to the right person' do
      @mail.to.should == [bob.email]
    end

    it "FROM: contains the sender's name" do
      @mail["From"].to_s.should == "\"#{@cnv.author.name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>"
    end

    it 'SUBJECT: has a snippet of the post contents' do
      @mail.subject.should == @cnv.subject
    end

    it 'SUBJECT: has "Re:" if not the first message in a conversation' do
      @cnv.messages << Message.new(:text => 'yo', :author => eve.person)
      @mail = Notifier.private_message(bob.id, @cnv.author.id, @cnv.messages.last.id)

      @mail.subject.should == "Re: #{@cnv.subject}"
    end

    it 'BODY: contains the message text' do
      @mail.body.encoded.should include(@cnv.messages.first.text)
    end

    it 'should not include translation fallback' do
      @mail.body.encoded.should_not include(I18n.translate 'notifier.a_post_you_shared')
    end
  end

  context "comments" do
    let(:commented_post) {bob.post(:status_message, :text => "It's really sunny outside today, and this is a super long status message!  #notreally", :to => :all)}
    let(:comment) { eve.comment!(commented_post, "Totally is")}

    describe ".comment_on_post" do
      let(:comment_mail) {Notifier.comment_on_post(bob.id, person.id, comment.id).deliver}

      it 'TO: goes to the right person' do
        comment_mail.to.should == [bob.email]
      end

      it "FROM: contains the sender's name" do
        comment_mail["From"].to_s.should == "\"#{eve.name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>"
      end

      it 'SUBJECT: has a snippet of the post contents' do
        comment_mail.subject.should == "Re: #{truncate(commented_post.raw_message, :length => 70)}"
      end

      context 'BODY' do
        it "contains the comment" do
          comment_mail.body.encoded.should include(comment.text)
        end

        it "contains the original post's link" do
          comment_mail.body.encoded.include?("#{comment.post.id.to_s}").should be true
        end

        it 'should not include translation fallback' do
          comment_mail.body.encoded.should_not include(I18n.translate 'notifier.a_post_you_shared')
        end
      end

      [:reshare, :activity_streams_photo].each do |post_type|
        context post_type.to_s do
          let(:commented_post) { FactoryGirl.create(post_type, :author => bob.person) }
          it 'succeeds' do
            proc {
              comment_mail
            }.should_not raise_error
          end
        end
      end
    end

    describe ".also_commented" do
      let(:comment_mail) { Notifier.also_commented(bob.id, person.id, comment.id) }

      it 'TO: goes to the right person' do
        comment_mail.to.should == [bob.email]
      end

      it 'FROM: has the name of person commenting as the sender' do
        comment_mail["From"].to_s.should == "\"#{eve.name} (Diaspora*)\" <#{AppConfig[:smtp_sender_address]}>"
      end

      it 'SUBJECT: has a snippet of the post contents' do
        comment_mail.subject.should == "Re: #{truncate(commented_post.raw_message, :length => 70)}"
      end

      context 'BODY' do
        it "contains the comment" do
          comment_mail.body.encoded.should include(comment.text)
        end

        it "contains the original post's link" do
          comment_mail.body.encoded.include?("#{comment.post.id.to_s}").should be true
        end

        it 'should not include translation fallback' do
          comment_mail.body.encoded.should_not include(I18n.translate 'notifier.a_post_you_shared')
        end
      end
      [:reshare, :activity_streams_photo].each do |post_type|
        context post_type.to_s do
          let(:commented_post) { FactoryGirl.create(post_type, :author => bob.person) }
          it 'succeeds' do
            proc {
              comment_mail
            }.should_not raise_error
          end
        end
      end
    end

    describe ".confirm_email" do
      before do
        bob.update_attribute(:unconfirmed_email, "my@newemail.com")
        @confirm_email = Notifier.confirm_email(bob.id)
      end

      it 'goes to the right person' do
        @confirm_email.to.should == [bob.unconfirmed_email]
      end

      it 'has the unconfirmed emil in the subject' do
        @confirm_email.subject.should include(bob.unconfirmed_email)
      end

      it 'has the unconfirmed emil in the body' do
        @confirm_email.body.encoded.should include(bob.unconfirmed_email)
      end

      it 'has the receivers name in the body' do
        @confirm_email.body.encoded.should include(bob.person.profile.first_name)
      end

      it 'has the activation link in the body' do
        @confirm_email.body.encoded.should include(confirm_email_url(:token => bob.confirm_email_token))
      end
    end
  end

  describe 'hashtags' do
    it 'escapes hashtags' do
      mails = Notifier.admin("#Welcome to bureaucracy!", [bob])
      mails.length.should == 1
      mail = mails.first
      mail.body.encoded.should match "<p><a href=\"http://localhost:9887/tags/welcome\">#Welcome</a> to bureaucracy!</p>"
    end
  end
end

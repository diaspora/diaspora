require 'spec_helper'

describe Notifier, :type => :mailer do
  let(:person) { FactoryGirl.create(:person) }

  before do
    Notifier.deliveries = []
  end

  describe '.administrative' do
    it 'mails a user' do
      mails = Notifier.admin("Welcome to bureaucracy!", [bob])
      expect(mails.length).to eq(1)
      mail = mails.first
      expect(mail.to).to eq([bob.email])
      expect(mail.body.encoded).to match /Welcome to bureaucracy!/
      expect(mail.body.encoded).to match /#{bob.username}/
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
        expect(mails.length).to eq(5)
        mails.each{|mail|
          this_user = @users.detect{|u| mail.to == [u.email]}
          expect(mail.body.encoded).to match /Welcome to bureaucracy!/
          expect(mail.body.encoded).to match /#{this_user.username}/
        }
      end

      it "has attachments" do
        mails = Notifier.admin("Welcome to bureaucracy!", @users, :attachments => [{:name => "retention stats", :file => "here is some file content"}])
        expect(mails.length).to eq(5)
        mails.each{|mail|
          expect(mail.attachments.count).to eq(1)
        }
      end
    end
  end

  describe '.single_admin' do
    it 'mails a user' do
      mail = Notifier.single_admin("Welcome to bureaucracy!", bob)
      expect(mail.to).to eq([bob.email])
      expect(mail.body.encoded).to match /Welcome to bureaucracy!/
      expect(mail.body.encoded).to match /#{bob.username}/
    end

    it 'has the layout' do
      mail = Notifier.single_admin("Welcome to bureaucracy!", bob)
      expect(mail.body.encoded).to match /change your notification settings/
    end

    it 'has an optional attachment' do
      mail = Notifier.single_admin("Welcome to bureaucracy!", bob, :attachments => [{:name => "retention stats", :file => "here is some file content"}])
      expect(mail.attachments.length).to eq(1)
    end
  end

  describe ".started_sharing" do
    let!(:request_mail) { Notifier.started_sharing(bob.id, person.id) }

    it 'goes to the right person' do
      expect(request_mail.to).to eq([bob.email])
    end

    it 'has the name of person sending the request' do
      expect(request_mail.body.encoded.include?(person.name)).to be true
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
      expect(@mail.to).to eq([@user.email])
    end

    it 'SUBJECT: has the name of person mentioning in the subject' do
      expect(@mail.subject).to include(@sm.author.name)
    end

    it 'has the post text in the body' do
      expect(@mail.body.encoded).to include(@sm.text)
    end

    it 'should not include translation fallback' do
      expect(@mail.body.encoded).not_to include(I18n.translate 'notifier.a_post_you_shared')
    end
  end

  describe ".liked" do
    before do
      @sm = FactoryGirl.create(:status_message, :author => alice.person)
      @like = @sm.likes.create!(:author => bob.person)
      @mail = Notifier.liked(alice.id, @like.author.id, @like.id)
    end

    it 'TO: goes to the right person' do
      expect(@mail.to).to eq([alice.email])
    end

    it 'BODY: contains the truncated original post' do
      expect(@mail.body.encoded).to include(@sm.message.plain_text)
    end

    it 'BODY: contains the name of person liking' do
      expect(@mail.body.encoded).to include(@like.author.name)
    end

    it 'should not include translation fallback' do
      expect(@mail.body.encoded).not_to include(I18n.translate 'notifier.a_post_you_shared')
    end

    it 'can handle a reshare' do
      reshare = FactoryGirl.create(:reshare)
      like = reshare.likes.create!(:author => bob.person)
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
      expect(@mail.to).to eq([alice.email])
    end

    it 'BODY: contains the truncated original post' do
      expect(@mail.body.encoded).to include(@sm.message.plain_text)
    end

    it 'BODY: contains the name of person liking' do
      expect(@mail.body.encoded).to include(@reshare.author.name)
    end

    it 'should not include translation fallback' do
      expect(@mail.body.encoded).not_to include(I18n.translate 'notifier.a_post_you_shared')
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
      expect(@mail.to).to eq([bob.email])
    end

    it "FROM: contains the sender's name" do
      expect(@mail["From"].to_s).to eq("\"#{@cnv.author.name} (diaspora*)\" <#{AppConfig.mail.sender_address}>")
    end

    it 'SUBJECT: has a snippet of the post contents' do
      expect(@mail.subject).to eq(@cnv.subject)
    end

    it 'SUBJECT: has "Re:" if not the first message in a conversation' do
      @cnv.messages << Message.new(:text => 'yo', :author => eve.person)
      @mail = Notifier.private_message(bob.id, @cnv.author.id, @cnv.messages.last.id)

      expect(@mail.subject).to eq("Re: #{@cnv.subject}")
    end

    it 'BODY: contains the message text' do
      expect(@mail.body.encoded).to include(@cnv.messages.first.text)
    end

    it 'should not include translation fallback' do
      expect(@mail.body.encoded).not_to include(I18n.translate 'notifier.a_post_you_shared')
    end
  end

  context "comments" do
    let(:commented_post) {bob.post(:status_message, :text => "### Headline \r\n It's **really** sunny outside today, and this is a super long status message!  #notreally", :to => :all)}
    let(:comment) { eve.comment!(commented_post, "Totally is")}

    describe ".comment_on_post" do
      let(:comment_mail) {Notifier.comment_on_post(bob.id, person.id, comment.id).deliver}

      it 'TO: goes to the right person' do
        expect(comment_mail.to).to eq([bob.email])
      end

      it "FROM: contains the sender's name" do
        expect(comment_mail["From"].to_s).to eq("\"#{eve.name} (diaspora*)\" <#{AppConfig.mail.sender_address}>")
      end

      it 'SUBJECT: has a snippet of the post contents, without markdown and without newlines' do
        expect(comment_mail.subject).to eq("Re: Headline")
      end

      context 'BODY' do
        it "contains the comment" do
          expect(comment_mail.body.encoded).to include(comment.text)
        end

        it "contains the original post's link" do
          expect(comment_mail.body.encoded.include?("#{comment.post.id.to_s}")).to be true
        end

        it 'should not include translation fallback' do
          expect(comment_mail.body.encoded).not_to include(I18n.translate 'notifier.a_post_you_shared')
        end
      end

      [:reshare].each do |post_type|
        context post_type.to_s do
          let(:commented_post) { FactoryGirl.create(post_type, :author => bob.person) }
          it 'succeeds' do
            expect {
              comment_mail
            }.not_to raise_error
          end
        end
      end
    end

    describe ".also_commented" do
      let(:comment_mail) { Notifier.also_commented(bob.id, person.id, comment.id) }

      it 'TO: goes to the right person' do
        expect(comment_mail.to).to eq([bob.email])
      end

      it 'FROM: has the name of person commenting as the sender' do
        expect(comment_mail["From"].to_s).to eq("\"#{eve.name} (diaspora*)\" <#{AppConfig.mail.sender_address}>")
      end

      it 'SUBJECT: has a snippet of the post contents, without markdown and without newlines' do
        expect(comment_mail.subject).to eq("Re: Headline")
      end

      context 'BODY' do
        it "contains the comment" do
          expect(comment_mail.body.encoded).to include(comment.text)
        end

        it "contains the original post's link" do
          expect(comment_mail.body.encoded.include?("#{comment.post.id.to_s}")).to be true
        end

        it 'should not include translation fallback' do
          expect(comment_mail.body.encoded).not_to include(I18n.translate 'notifier.a_post_you_shared')
        end
      end
      [:reshare].each do |post_type|
        context post_type.to_s do
          let(:commented_post) { FactoryGirl.create(post_type, :author => bob.person) }
          it 'succeeds' do
            expect {
              comment_mail
            }.not_to raise_error
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
        expect(@confirm_email.to).to eq([bob.unconfirmed_email])
      end

      it 'has the unconfirmed emil in the subject' do
        expect(@confirm_email.subject).to include(bob.unconfirmed_email)
      end

      it 'has the unconfirmed emil in the body' do
        expect(@confirm_email.body.encoded).to include(bob.unconfirmed_email)
      end

      it 'has the receivers name in the body' do
        expect(@confirm_email.body.encoded).to include(bob.person.profile.first_name)
      end

      it 'has the activation link in the body' do
        expect(@confirm_email.body.encoded).to include(confirm_email_url(:token => bob.confirm_email_token))
      end
    end
  end

  describe 'hashtags' do
    it 'escapes hashtags' do
      mails = Notifier.admin("#Welcome to bureaucracy!", [bob])
      expect(mails.length).to eq(1)
      mail = mails.first
      expect(mail.body.encoded).to match "<p><a href=\"http://localhost:9887/tags/welcome\">#Welcome</a> to bureaucracy!</p>"
    end
  end

  describe "base" do
    it "handles idn addresses" do
      # user = FactoryGirl.create(:user, email: "ŧoo@ŧexample.com")
      bob.update_attribute(:email, "ŧoo@ŧexample.com")
      expect {
        Notifier.started_sharing(bob.id, person.id)
      }.to_not raise_error
    end
  end
end

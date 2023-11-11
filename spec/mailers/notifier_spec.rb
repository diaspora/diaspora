# frozen_string_literal: true

describe Notifier, type: :mailer do
  let(:person) { FactoryBot.create(:person) }
  let(:pod_name) { AppConfig.settings.pod_name }


  before do
    Notifier.deliveries = []
  end

  describe ".administrative" do
    it "mails a user" do
      mails = Notifier.admin("Welcome to bureaucracy!", [bob])
      expect(mails.length).to eq(1)
      mail = mails.first
      expect(mail.to).to eq([bob.email])
      expect(mail.body.encoded).to match /Welcome to bureaucracy!/
      expect(mail.body.encoded).to match /#{bob.username}/
    end

    context "mails a bunch of users" do
      before do
        @users = []
        5.times do
          @users << FactoryBot.create(:user)
        end
      end
      it "has a body" do
        mails = Notifier.admin("Welcome to bureaucracy!", @users)
        expect(mails.length).to eq(5)
        mails.each {|mail|
          this_user = @users.find {|u| mail.to == [u.email] }
          expect(mail.body.encoded).to match /Welcome to bureaucracy!/
          expect(mail.body.encoded).to match /#{this_user.username}/
        }
      end

      it "has attachments" do
        mails = Notifier.admin("Welcome to bureaucracy!", @users,
                               attachments: [{name: "retention stats", file: "here is some file content"}])
        expect(mails.length).to eq(5)
        mails.each {|mail|
          expect(mail.attachments.count).to eq(1)
        }
      end
    end
  end

  describe ".single_admin" do
    it "mails a user" do
      mail = Notifier.single_admin("Welcome to bureaucracy!", bob)
      expect(mail.to).to eq([bob.email])
      expect(mail.body.encoded).to match /Welcome to bureaucracy!/
      expect(mail.body.encoded).to match /#{bob.username}/
    end

    it "has the layout" do
      mail = Notifier.single_admin("Welcome to bureaucracy!", bob)
      expect(mail.body.encoded).to match /change your notification settings/
    end

    it "has an optional attachment" do
      mail = Notifier.single_admin("Welcome to bureaucracy!", bob,
                                   attachments: [{name: "retention stats", file: "here is some file content"}])
      expect(mail.attachments.length).to eq(1)
    end
  end

  describe ".started_sharing" do
    let!(:request_mail) { Notifier.send_notification("started_sharing", bob.id, person.id) }

    it "goes to the right person" do
      expect(request_mail.to).to eq([bob.email])
    end

    it "has the name of person sending the request" do
      expect(request_mail.body.encoded).to include(person.name)
    end
  end

  describe ".contacts_birthday" do
    let(:contact) { alice.contact_for(bob.person) }
    let(:mail) { Notifier.send_notification("contacts_birthday", alice.id, nil, bob.person.id) }

    it "TO: goes to the right person" do
      expect(mail.to).to eq([alice.email])
    end

    it "SUBJECT: has the name of birthday person in the subject" do
      expect(mail.subject).to include(bob.person.name)
    end

    it "has a link to the birthday profile in the body" do
      expect(mail.body.encoded).to include(user_profile_url(bob.person.username))
    end
  end

  describe ".mentioned" do
    before do
      @user = alice
      @post = FactoryBot.create(:status_message, public: true)
      @mention = Mention.create(person: @user.person, mentions_container: @post)

      @mail = Notifier.send_notification("mentioned", @user.id, @post.author.id, @mention.id)
    end

    it "TO: goes to the right person" do
      expect(@mail.to).to eq([@user.email])
    end

    it "SUBJECT: has the name of person mentioning in the subject" do
      expect(@mail.subject).to include(@post.author.name)
    end

    it "IN-REPLY-TO and REFERENCES: references the mentioning post" do
      expect(@mail.in_reply_to).to eq("#{@post.guid}@#{AppConfig.pod_uri.host}")
      expect(@mail.references).to eq("#{@post.guid}@#{AppConfig.pod_uri.host}")
    end

    it "has the post text in the body" do
      expect(@mail.body.encoded).to include(@post.text)
    end
  end

  describe ".mentioned_in_comment" do
    let(:user) { alice }
    let(:comment) { FactoryBot.create(:comment) }
    let(:mention) { Mention.create(person: user.person, mentions_container: comment) }
    let(:mail) { Notifier.send_notification("mentioned_in_comment", user.id, comment.author.id, mention.id) }

    it "TO: goes to the right person" do
      expect(mail.to).to eq([user.email])
    end

    it "SUBJECT: has the name of person mentioning in the subject" do
      expect(mail.subject).to include(comment.author.name)
    end

    it "IN-REPLY-TO and REFERENCES: references the commented post" do
      expect(mail.in_reply_to).to eq("#{comment.parent.guid}@#{AppConfig.pod_uri.host}")
      expect(mail.references).to eq("#{comment.parent.guid}@#{AppConfig.pod_uri.host}")
    end

    it "has the comment link in the body" do
      expect(mail.body.encoded).to include(post_url(comment.parent, anchor: comment.guid))
    end

    it "renders proper wording when limited" do
      expect(mail.body.encoded).to include(I18n.translate("notifier.mentioned_in_comment.limited_post"))
    end

    it "renders comment text when public" do
      comment.parent.update(public: true)
      expect(mail.body.encoded).to include(comment.message.plain_text_without_markdown)
    end
  end

  describe ".mentioned limited" do
    before do
      @user = alice
      @post = FactoryBot.create(:status_message, public: false)
      @mention = Mention.create(person: @user.person, mentions_container: @post)

      @mail = Notifier.send_notification("mentioned", @user.id, @post.author.id, @mention.id)
    end

    it "TO: goes to the right person" do
      expect(@mail.to).to eq([@user.email])
    end

    it "SUBJECT: has the name of person mentioning in the subject" do
      expect(@mail.subject).to include(@post.author.name)
    end

    it "has the post text not in the body" do
      expect(@mail.body.encoded).not_to include(@post.text)
    end
  end

  describe ".liked" do
    before do
      @post = FactoryBot.create(:status_message, author: alice.person, public: true)
      @like = @post.likes.create!(author: bob.person)
      @mail = Notifier.send_notification("liked", alice.id, @like.author.id, @like.id)
    end

    it "TO: goes to the right person" do
      expect(@mail.to).to eq([alice.email])
    end

    it "BODY: contains the original post" do
      expect(@mail.body.encoded).to include(@post.message.plain_text)
    end

    it "BODY: contains the name of person liking" do
      expect(@mail.body.encoded).to include(@like.author.name)
    end

    it "can handle a reshare" do
      reshare = FactoryBot.create(:reshare)
      like = reshare.likes.create!(author: bob.person)
      Notifier.send_notification("liked", alice.id, like.author.id, like.id)
    end

    it "can handle status_messages without text" do
      photo = FactoryBot.create(:photo, public: true, author: alice.person)
      status = FactoryBot.create(:status_message, author: alice.person, text: nil, photos: [photo], public: true)
      like = status.likes.create!(author: bob.person)
      mail = Notifier.send_notification("liked", alice.id, like.author.id, like.id)
      expect(mail.body.encoded).to include(I18n.t("posts.show.photos_by", count: 1, author: alice.name))
    end
  end

  describe ".liked_comment" do
    before do
      @post = FactoryBot.create(:status_message, author: alice.person, public: true)
      @comment = FactoryBot.create(:comment, author: alice.person, post: @post)
      @like = @comment.likes.create!(author: bob.person)
      @mail = Notifier.send_notification("liked_comment", alice.id, @like.author.id, @like.id)
    end

    it "TO: goes to the right person" do
      expect(@mail.to).to eq([alice.email])
    end

    it "BODY: contains the original comment" do
      expect(@mail.body.encoded).to include(@comment.message.plain_text)
    end

    it "BODY: contains the name of person liking" do
      expect(@mail.body.encoded).to include(@like.author.name)
    end
  end

  describe ".reshared" do
    before do
      @post = FactoryBot.create(:status_message, author: alice.person, public: true)
      @reshare = FactoryBot.create(:reshare, root: @post, author: bob.person)
      @mail = Notifier.send_notification("reshared", alice.id, @reshare.author.id, @reshare.id)
    end

    it "TO: goes to the right person" do
      expect(@mail.to).to eq([alice.email])
    end

    it "IN-REPLY-TO and REFERENCES: references the reshared post" do
      expect(@mail.in_reply_to).to eq("#{@post.guid}@#{AppConfig.pod_uri.host}")
      expect(@mail.references).to eq("#{@post.guid}@#{AppConfig.pod_uri.host}")
    end

    it "BODY: contains the truncated original post" do
      expect(@mail.body.encoded).to include(@post.message.plain_text)
    end

    it "BODY: contains the name of person liking" do
      expect(@mail.body.encoded).to include(@reshare.author.name)
    end
  end

  describe ".private_message" do
    before do
      @user2 = bob
      @participant_ids = @user2.contacts.map {|c| c.person.id } + [@user2.person.id]

      @create_hash = {
        author:              @user2.person,
        participant_ids:     @participant_ids,
        subject:             "cool stuff",
        messages_attributes: [{author: @user2.person, text: "hey"}]
      }

      @cnv = Conversation.create(@create_hash)

      @mail = Notifier.send_notification("private_message", bob.id, @cnv.author.id, @cnv.messages.first.id)
    end

    it "TO: goes to the right person" do
      expect(@mail.to).to eq([bob.email])
    end

    it "FROM: contains the sender's name" do
      expect(@mail["From"].to_s).to eq("\"#{pod_name} (#{@cnv.author.name})\" <#{AppConfig.mail.sender_address}>")
    end

    it "FROM: removes emojis from sender's name" do
      bob.person.profile.update!(first_name: "1️⃣2️3️⃣ Numbers 123", last_name: "👍✅👍🏻Emojis😀😇❄️")
      expect(@mail["From"].to_s).to eq("\"#{pod_name} (Numbers 123 Emojis)\" <#{AppConfig.mail.sender_address}>")
    end

    it "should use a generic subject" do
      expect(@mail.subject).to eq(I18n.translate("notifier.private_message.subject"))
    end

    it "SUBJECT: should not has a snippet of the private message contents" do
      expect(@mail.subject).not_to include(@cnv.subject)
    end

    it "IN-REPLY-TO and REFERENCES: references the containing conversation" do
      expect(@mail.in_reply_to).to eq("#{@cnv.guid}@#{AppConfig.pod_uri.host}")
      expect(@mail.references).to eq("#{@cnv.guid}@#{AppConfig.pod_uri.host}")
    end

    it "BODY: does not contain the message text" do
      expect(@mail.body.encoded).not_to include(@cnv.messages.first.text)
    end
  end

  context "comments" do
    let(:commented_post) {
      bob.post(:status_message,
               text:   "### Headline \r\n It's **really** sunny outside today, and this is a super long status message!  #notreally",
               to:     :all,
               public: true)
    }
    let(:comment) { eve.comment!(commented_post, "Totally is") }

    describe ".comment_on_post" do
      let(:comment_mail) {
        Notifier.send_notification("comment_on_post", bob.id, eve.person.id, comment.id).deliver_now
      }

      it "TO: goes to the right person" do
        expect(comment_mail.to).to eq([bob.email])
      end

      it "FROM: contains the sender's name" do
        expect(comment_mail["From"].to_s).to eq("\"#{pod_name} (#{eve.name})\" <#{AppConfig.mail.sender_address}>")
      end

      it "FROM: removes emojis from sender's name" do
        eve.person.profile.update!(first_name: "1️⃣2️3️⃣ Numbers 123", last_name: "👍✅👍🏻Emojis😀😇❄️")
        expect(comment_mail["From"].to_s)
          .to eq("\"#{pod_name} (Numbers 123 Emojis)\" <#{AppConfig.mail.sender_address}>")
      end

      it "SUBJECT: has a snippet of the post contents, without markdown and without newlines" do
        expect(comment_mail.subject).to eq("Re: Headline")
      end

      context "BODY" do
        it "contains the comment" do
          expect(comment_mail.body.encoded).to include(comment.text)
        end

        it "contains the original post's link with comment anchor" do
          expect(comment_mail.body.encoded).to include("#{comment.post.id}##{comment.guid}")
        end
      end

      [:reshare].each do |post_type|
        context post_type.to_s do
          let(:commented_post) { FactoryBot.create(post_type, author: bob.person) }
          it "succeeds" do
            expect {
              comment_mail
            }.not_to raise_error
          end
        end
      end
    end

    describe ".also_commented" do
      let(:comment_mail) { Notifier.send_notification("also_commented", bob.id, eve.person.id, comment.id) }

      it "TO: goes to the right person" do
        expect(comment_mail.to).to eq([bob.email])
      end

      it "FROM: has the name of person commenting as the sender" do
        expect(comment_mail["From"].to_s).to eq("\"#{pod_name} (#{eve.name})\" <#{AppConfig.mail.sender_address}>")
      end

      it "SUBJECT: has a snippet of the post contents, without markdown and without newlines" do
        expect(comment_mail.subject).to eq("Re: Headline")
      end

      it "IN-REPLY-TO and REFERENCES: references the commented post" do
        expect(comment_mail.in_reply_to).to eq("#{comment.parent.guid}@#{AppConfig.pod_uri.host}")
        expect(comment_mail.references).to eq("#{comment.parent.guid}@#{AppConfig.pod_uri.host}")
      end

      context "BODY" do
        it "contains the comment" do
          expect(comment_mail.body.encoded).to include(comment.text)
        end

        it "contains the original post's link with comment anchor" do
          expect(comment_mail.body.encoded).to include("#{comment.post.id}##{comment.guid}")
        end
      end
      [:reshare].each do |post_type|
        context post_type.to_s do
          let(:commented_post) { FactoryBot.create(post_type, author: bob.person) }
          it "succeeds" do
            expect {
              comment_mail
            }.not_to raise_error
          end
        end
      end
    end
  end

  context "limited post" do
    let(:limited_post) {
      alice.post(:status_message, to: :all, public: false,
        text: "### Limited headline \r\n It's **really** sunny outside today")
    }

    context "comments" do
      let(:comment) { bob.comment!(limited_post, "Totally is") }

      describe ".also_commented" do
        let(:mail) { Notifier.send_notification("also_commented", alice.id, bob.person.id, comment.id) }

        it "TO: goes to the right person" do
          expect(mail.to).to eq([alice.email])
        end

        it "FROM: contains the sender's name" do
          expect(mail["From"].to_s).to eq("\"#{pod_name} (#{bob.name})\" <#{AppConfig.mail.sender_address}>")
        end

        it "FROM: removes emojis from sender's name" do
          bob.person.profile.update!(first_name: "1️⃣2️3️⃣ Numbers 123", last_name: "👍✅👍🏻Emojis😀😇❄️")
          expect(mail["From"].to_s).to eq("\"#{pod_name} (Numbers 123 Emojis)\" <#{AppConfig.mail.sender_address}>")
        end

        it "SUBJECT: does not show the limited post" do
          expect(mail.subject).not_to include("Limited headline")
        end

        it "BODY: does not show limited message" do
          expect(mail.body.encoded).not_to include("Limited headline")
        end

        it "BODY: does not show the comment" do
          expect(mail.body.encoded).not_to include("Totally is")
        end
      end

      describe ".comment_on_post" do
        let(:comment) { bob.comment!(limited_post, "Totally is") }
        let(:mail) { Notifier.send_notification("comment_on_post", alice.id, bob.person.id, comment.id) }

        it "TO: goes to the right person" do
          expect(mail.to).to eq([alice.email])
        end

        it "FROM: contains the sender's name" do
          expect(mail["From"].to_s).to eq("\"#{pod_name} (#{bob.name})\" <#{AppConfig.mail.sender_address}>")
        end

        it "FROM: removes emojis from sender's name" do
          bob.person.profile.update!(first_name: "1️⃣2️3️⃣ Numbers 123", last_name: "👍✅👍🏻Emojis😀😇❄️")
          expect(mail["From"].to_s).to eq("\"#{pod_name} (Numbers 123 Emojis)\" <#{AppConfig.mail.sender_address}>")
        end

        it "SUBJECT: does not show the limited post" do
          expect(mail.subject).not_to include("Limited headline")
        end

        it "IN-REPLY-TO and REFERENCES: references the commented post" do
          expect(mail.in_reply_to).to eq("#{comment.parent.guid}@#{AppConfig.pod_uri.host}")
          expect(mail.references).to eq("#{comment.parent.guid}@#{AppConfig.pod_uri.host}")
        end

        it "BODY: does not show the limited post" do
          expect(mail.body.encoded).not_to include("Limited headline")
        end

        it "BODY: does not show the comment" do
          expect(mail.body.encoded).not_to include("Totally is")
        end
      end
    end

    describe ".liked" do
      let(:like) { bob.like!(limited_post) }
      let(:mail) { Notifier.send_notification("liked", alice.id, bob.person.id, like.id) }

      it "TO: goes to the right person" do
        expect(mail.to).to eq([alice.email])
      end

      it "FROM: contains the sender's name" do
        expect(mail["From"].to_s).to eq("\"#{pod_name} (#{bob.name})\" <#{AppConfig.mail.sender_address}>")
      end

      it "FROM: removes emojis from sender's name" do
        bob.person.profile.update!(first_name: "1️⃣2️3️⃣ Numbers 123", last_name: "👍✅👍🏻Emojis😀😇❄️")
        expect(mail["From"].to_s).to eq("\"#{pod_name} (Numbers 123 Emojis)\" <#{AppConfig.mail.sender_address}>")
      end

      it "SUBJECT: does not show the limited post" do
        expect(mail.subject).not_to include("Limited headline")
      end

      it "IN-REPLY-TO and REFERENCES: references the liked post" do
        expect(mail.in_reply_to).to eq("#{like.parent.guid}@#{AppConfig.pod_uri.host}")
        expect(mail.references).to eq("#{like.parent.guid}@#{AppConfig.pod_uri.host}")
      end

      it "BODY: does not show the limited post" do
        expect(mail.body.encoded).not_to include("Limited headline")
      end

      it "BODY: contains the name of person liking" do
        expect(mail.body.encoded).to include(bob.name)
      end
    end

    describe ".liked_comment" do
      let(:comment) { alice.comment!(limited_post, "Totally is") }
      let(:like) { bob.like_comment!(comment) }
      let(:mail) { Notifier.send_notification("liked_comment", alice.id, bob.person.id, like.id) }

      it "TO: goes to the right person" do
        expect(mail.to).to eq([alice.email])
      end

      it "FROM: contains the sender's name" do
        expect(mail["From"].to_s).to eq("\"#{pod_name} (#{bob.name})\" <#{AppConfig.mail.sender_address}>")
      end

      it "FROM: removes emojis from sender's name" do
        bob.person.profile.update!(first_name: "1️⃣2️3️⃣ Numbers 123", last_name: "👍✅👍🏻Emojis😀😇❄️")
        expect(mail["From"].to_s).to eq("\"#{pod_name} (Numbers 123 Emojis)\" <#{AppConfig.mail.sender_address}>")
      end

      it "SUBJECT: does not show the limited comment" do
        expect(mail.subject).not_to include("Totally is")
      end

      it "IN-REPLY-TO and REFERENCES: references the liked post" do
        expect(mail.in_reply_to).to eq("#{limited_post.guid}@#{AppConfig.pod_uri.host}")
        expect(mail.references).to eq("#{limited_post.guid}@#{AppConfig.pod_uri.host}")
      end

      it "BODY: does not show the limited post" do
        expect(mail.body.encoded).not_to include("Totally is")
      end

      it "BODY: contains the name of person liking" do
        expect(mail.body.encoded).to include(bob.name)
      end
    end
  end

  describe ".confirm_email" do
    before do
      bob.update_attribute(:unconfirmed_email, "my@newemail.com")
      @confirm_email = Notifier.send_notification("confirm_email", bob.id)
    end

    it "goes to the right person" do
      expect(@confirm_email.to).to eq([bob.unconfirmed_email])
    end

    it "FROM: header should be the pod name with default sender address" do
      expect(@confirm_email["From"].to_s).to eq("#{pod_name} <#{AppConfig.mail.sender_address}>")
    end

    it "has the unconfirmed email in the subject" do
      expect(@confirm_email.subject).to include(bob.unconfirmed_email)
    end

    it "has the unconfirmed emil in the body" do
      expect(@confirm_email.body.encoded).to include(bob.unconfirmed_email)
    end

    it "has the receivers name in the body" do
      expect(@confirm_email.body.encoded).to include(bob.person.profile.first_name)
    end

    it "has the activation link in the body" do
      expect(@confirm_email.body.encoded).to include(confirm_email_url(token: bob.confirm_email_token))
    end
  end

  describe ".invite" do
    let(:email) { Notifier.invite(alice.email, bob, "1234", "en") }

    it "goes to the right person" do
      expect(email.to).to eq([alice.email])
    end

    it "FROM: header should be the pod name + default sender address" do
      expect(email["From"].to_s).to eq("#{pod_name} <#{AppConfig.mail.sender_address}>")
    end

    it "has the correct subject" do
      expect(email.subject).to eq(I18n.translate("notifier.invited_you", name: bob.name))
    end

    it "has the inviter name in the body" do
      expect(email.body.encoded).to include("#{bob.name} (#{bob.diaspora_handle})")
    end

    it "has the inviter id if the name is nil" do
      bob.person.profile.update(first_name: "", last_name: "")
      mail = Notifier.invite(alice.email, bob, "1234", "en")
      expect(email.body.encoded).to_not include("#{bob.name} (#{bob.diaspora_handle})")
      expect(mail.body.encoded).to include(bob.person.diaspora_handle)
    end

    it "has the invitation code in the body" do
      expect(email.body.encoded).to include("/i/1234")
    end
  end

  describe ".csrf_token_fail" do
    let(:email) { Notifier.send_notification("csrf_token_fail", alice.id) }

    it "goes to the right person" do
      expect(email.to).to eq([alice.email])
    end

    it "FROM: header should be the pod name + default sender address" do
      expect(email["From"].to_s).to eq("#{pod_name} <#{AppConfig.mail.sender_address}>")
    end

    it "has the correct subject" do
      expect(email.subject).to eq(I18n.translate("notifier.csrf_token_fail.subject", name: alice.name))
    end

    it "has the receivers name in the body" do
      expect(email.body.encoded).to include(alice.person.profile.first_name)
    end

    it "has some informative text in the body" do
      email.body.parts.each do |part|
        expect(part.decoded).to include("https://owasp.org/www-community/attacks/csrf")
      end
    end
  end

  describe "hashtags" do
    it "escapes hashtags" do
      status = FactoryBot.create(:status_message, author: alice.person, text: "#Welcome to bureaucracy!", public: true)
      like = status.likes.create!(author: bob.person)
      mail = Notifier.send_notification("liked", alice.id, like.author.id, like.id)
      expect(mail.body.encoded).to match(
        "<p><a href=\"#{AppConfig.url_to(tag_path('welcome'))}\">#Welcome</a> to bureaucracy!</p>"
      )
    end
  end

  describe "base" do
    it "handles idn addresses" do
      bob.update_attribute(:email, "ŧoo@ŧexample.com")
      expect {
        Notifier.send_notification("started_sharing", bob.id, person.id)
      }.to_not raise_error
    end

    it "FROM: header should be 'pod_name (username)' when there is no first and last name" do
      bob.person.profile.update(first_name: "", last_name: "")
      mail = Notifier.send_notification("started_sharing", alice.id, bob.person.id)
      expect(mail["From"].to_s).to eq("\"#{pod_name} (#{bob.person.username})\" <#{AppConfig.mail.sender_address}>")
    end
  end
end

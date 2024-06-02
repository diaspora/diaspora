# frozen_string_literal: true

describe PostService do
  let(:post) { alice.post(:status_message, text: "ohai", to: alice.aspects.first) }
  let(:public) { alice.post(:status_message, text: "hey", public: true) }

  describe "#find" do
    context "with user" do
      it "returns the post, if it is the users post" do
        expect(PostService.new(alice).find(post.id)).to eq(post)
      end

      it "returns the post, if the user can see the it" do
        expect(PostService.new(bob).find(post.id)).to eq(post)
      end

      it "returns the post, if it is public" do
        expect(PostService.new(eve).find(public.id)).to eq(public)
      end

      it "does not return the post, if the post cannot be found" do
        expect(PostService.new(alice).find("unknown")).to be_nil
      end

      it "does not return the post, if user cannot see the post" do
        expect(PostService.new(eve).find(post.id)).to be_nil
      end
    end

    context "without user" do
      it "returns the post, if it is public" do
        expect(PostService.new.find(public.id)).to eq(public)
      end

      it "does not return the post, if the post is private" do
        expect(PostService.new.find(post.id)).to be_nil
      end

      it "does not return the post, if the post cannot be found" do
        expect(PostService.new.find("unknown")).to be_nil
      end
    end
  end

  describe "#find!" do
    context "with user" do
      it "returns the post, if it is the users post" do
        expect(PostService.new(alice).find!(post.id)).to eq(post)
      end

      it "works with guid" do
        expect(PostService.new(alice).find!(post.guid)).to eq(post)
      end

      it "returns the post, if the user can see the it" do
        expect(PostService.new(bob).find!(post.id)).to eq(post)
      end

      it "returns the post, if it is public" do
        expect(PostService.new(eve).find!(public.id)).to eq(public)
      end

      it "RecordNotFound if the post cannot be found" do
        expect {
          PostService.new(alice).find!("unknown")
        }.to raise_error ActiveRecord::RecordNotFound, "could not find a post with id unknown for user #{alice.id}"
      end

      it "RecordNotFound if user cannot see the post" do
        expect {
          PostService.new(eve).find!(post.id)
        }.to raise_error ActiveRecord::RecordNotFound, "could not find a post with id #{post.id} for user #{eve.id}"
      end
    end

    context "without user" do
      it "returns the post, if it is public" do
        expect(PostService.new.find!(public.id)).to eq(public)
      end

      it "works with guid" do
        expect(PostService.new.find!(public.guid)).to eq(public)
      end

      it "NonPublic if the post is private" do
        expect {
          PostService.new.find!(post.id)
        }.to raise_error Diaspora::NonPublic
      end

      it "RecordNotFound if the post cannot be found" do
        expect {
          PostService.new.find!("unknown")
        }.to raise_error ActiveRecord::RecordNotFound, "could not find a post with id unknown"
      end
    end

    context "id/guid switch" do
      let(:public) { alice.post(:status_message, text: "ohai", public: true) }

      it "assumes ids less than 16 chars are ids and not guids" do
        post = Post.where(id: public.id)
        expect(Post).to receive(:where).with(hash_including(id: "123456789012345")).and_return(post).at_least(:once)
        PostService.new(alice).find!("123456789012345")
      end

      it "assumes ids more than (or equal to) 16 chars are actually guids" do
        post = Post.where(guid: public.guid)
        expect(Post).to receive(:where).with(hash_including(guid: "1234567890123456")).and_return(post).at_least(:once)
        PostService.new(alice).find!("1234567890123456")
      end
    end
  end

  describe "#mark_user_notifications" do
    let(:status_text) { text_mentioning(alice) }

    it "marks a corresponding notifications as read" do
      FactoryBot.create(:notification, recipient: alice, target: post, unread: true)
      FactoryBot.create(:notification, recipient: alice, target: post, unread: true)

      expect {
        PostService.new(alice).mark_user_notifications(post.id)
      }.to change(Notification.where(unread: true), :count).by(-2)
    end

    it "marks a corresponding mention notification as read" do
      mention_post = bob.post(:status_message, text: status_text, public: true)

      expect {
        PostService.new(alice).mark_user_notifications(mention_post.id)
      }.to change(Notification.where(unread: true), :count).by(-1)
    end

    it "marks a corresponding mention in comment notification as read" do
      notification = FactoryBot.create(:notification_mentioned_in_comment)
      status_message = notification.target.mentions_container.parent
      user = notification.recipient

      expect {
        PostService.new(user).mark_user_notifications(status_message.id)
      }.to change(Notification.where(unread: true), :count).by(-1)
    end

    it "does not change the update_at date/time for post notifications" do
      notification = Timecop.travel(1.minute.ago) do
        FactoryBot.create(:notification, recipient: alice, target: post, unread: true)
      end

      expect {
        PostService.new(alice).mark_user_notifications(post.id)
      }.not_to change { Notification.where(id: notification.id).pluck(:updated_at) }
    end

    it "does not change the update_at date/time for mention notifications" do
      mention_post = Timecop.travel(1.minute.ago) do
        bob.post(:status_message, text: status_text, public: true)
      end
      mention = mention_post.mentions.where(person_id: alice.person.id).first

      expect {
        PostService.new(alice).mark_user_notifications(post.id)
      }.not_to change { Notification.where(target_type: "Mention", target_id: mention.id).pluck(:updated_at) }
    end

    it "does nothing without a user" do
      expect_any_instance_of(PostService).not_to receive(:mark_comment_reshare_like_notifications_read).with(post.id)
      expect_any_instance_of(PostService).not_to receive(:mark_mention_notifications_read).with(post.id)
      PostService.new.mark_user_notifications(post.id)
    end

    context "for comments" do
      let(:comment) { post.comments.create(author: alice.person, text: "comment") }

      it "marks a corresponding notifications as read" do
        FactoryBot.create(:notification, recipient: alice, target: comment, unread: true)
        FactoryBot.create(:notification, recipient: alice, target: comment, unread: true)

        expect {
          PostService.new(alice).mark_user_notifications(post.id)
        }.to change(Notification.where(unread: true), :count).by(-2)
      end

      it "does not change the update_at date/time for comment notifications" do
        notification = Timecop.travel(1.minute.ago) do
          FactoryBot.create(:notification, recipient: alice, target: comment, unread: true)
        end

        expect {
          PostService.new(alice).mark_user_notifications(post.id)
        }.not_to(change { Notification.where(id: notification.id).pluck(:updated_at) })
      end

      it "does not change other users notifications" do
        alice_notification = FactoryBot.create(:notification, recipient: alice, target: comment, unread: true)
        bob_notification = FactoryBot.create(:notification, recipient: bob, target: comment, unread: true)

        PostService.new(alice).mark_user_notifications(post.id)

        expect(Notification.find(alice_notification.id).unread).to be_falsey
        expect(Notification.find(bob_notification.id).unread).to be_truthy
      end

      it "marks notifications for all comments on a post as read" do
        comment2 = post.comments.create(author: alice.person, text: "comment2")

        FactoryBot.create(:notification, recipient: alice, target: comment, unread: true)
        FactoryBot.create(:notification, recipient: alice, target: comment2, unread: true)

        expect {
          PostService.new(alice).mark_user_notifications(post.id)
        }.to change(Notification.where(unread: true), :count).by(-2)
      end
    end
  end

  describe "#destroy" do
    it "let a user delete his message" do
      PostService.new(alice).destroy(post.id)
      expect(StatusMessage.find_by_id(post.id)).to be_nil
    end

    it "sends a retraction on delete" do
      expect(alice).to receive(:retract).with(post)
      PostService.new(alice).destroy(post.id)
    end

    it "won't delete private post if explicitly unallowed" do
      expect {
        PostService.new(alice).destroy(post.id, false)
      }.to raise_error Diaspora::NonPublic
      expect(StatusMessage.find_by(id: post.id)).not_to be_nil
    end

    it "will not let you destroy posts visible to you but that you do not own" do
      expect {
        PostService.new(bob).destroy(post.id)
      }.to raise_error Diaspora::NotMine
      expect(StatusMessage.find_by_id(post.id)).not_to be_nil
    end

    it "will not let you destroy posts that are not visible to you" do
      expect {
        PostService.new(eve).destroy(post.id)
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect(StatusMessage.find_by_id(post.id)).not_to be_nil
    end
  end

  describe "#mentionable_in_comment" do
    describe "semi-integration test" do
      let(:post_author_attributes) { {first_name: "Ro#{r_str}"} }
      let(:post_author)  { FactoryBot.create(:person, post_author_attributes) }
      let(:current_user) { FactoryBot.create(:user_with_aspect) }
      let(:post_service) { PostService.new(current_user) }

      shared_context "with commenters and likers" do
        # randomize ids of the created people so that the test doesn't pass just because of
        # the id sequence matched against the expected ordering
        let(:ids) { (1..4).map {|i| Person.maximum(:id) + i }.shuffle }

        before do
          # in case when post_author has't been instantiated before this context, specify id
          # in order to avoid id conflict with the people generated here
          post_author_attributes.merge!(id: ids.max + 1)
        end

        let!(:commenter1) {
          FactoryBot.create(:person, id: ids.shift, first_name: "Ro1#{r_str}").tap {|person|
            FactoryBot.create(:comment, author: person, post: post)
          }
        }

        let!(:commenter2) {
          FactoryBot.create(:person, id: ids.shift, first_name: "Ro2#{r_str}").tap {|person|
            FactoryBot.create(:comment, author: person, post: post)
          }
        }

        let!(:liker1) {
          FactoryBot.create(:person, id: ids.shift, first_name: "Ro1#{r_str}").tap {|person|
            FactoryBot.create(:like, author: person, target: post)
          }
        }

        let!(:liker2) {
          FactoryBot.create(:person, id: ids.shift, first_name: "Ro2#{r_str}").tap {|person|
            FactoryBot.create(:like, author: person, target: post)
          }
        }
      end

      shared_context "with a current user's friend" do
        let!(:current_users_friend) {
          FactoryBot.create(:person).tap {|friend|
            current_user.contacts.create!(
              person:    friend,
              aspects:   [current_user.aspects.first],
              sharing:   true,
              receiving: true
            )
          }
        }
      end

      context "with private post" do
        let(:post) { FactoryBot.create(:status_message, text: "ohai", author: post_author) }

        context "when the post doesn't have a visibility for the current user" do
          it "doesn't find a post and raises an exception" do
            expect {
              post_service.mentionable_in_comment(post.id, "Ro")
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context "when the post has a visibility for the current user" do
          before do
            ShareVisibility.batch_import([current_user.id], post)
          end

          context "with commenters and likers" do
            include_context "with commenters and likers"

            it "returns mention suggestions in the correct order" do
              expected_suggestions = [
                post_author, commenter1, commenter2, liker1, liker2
              ]
              expect(post_service.mentionable_in_comment(post.id, "Ro")).to eq(expected_suggestions)
            end
          end

          context "with a current user's friend" do
            include_context "with a current user's friend"

            it "doesn't include a contact" do
              expect(post_service.mentionable_in_comment(post.id, current_users_friend.first_name)).to be_empty
            end
          end

          it "doesn't include a non contact" do
            expect(post_service.mentionable_in_comment(post.id, eve.person.first_name)).to be_empty
          end
        end
      end

      context "with public post" do
        let(:post) { FactoryBot.create(:status_message, text: "ohai", public: true, author: post_author) }

        context "with commenters and likers and with a current user's friend" do
          include_context "with commenters and likers"
          include_context "with a current user's friend"

          it "returns mention suggestions in the correct order" do
            result = post_service.mentionable_in_comment(post.id, "Ro").to_a
            expect(result.size).to be > 7
            # participants: post author, comments, likers
            expect(result[0..4]).to eq([post_author, commenter1, commenter2, liker1, liker2])
            # contacts
            expect(result[5]).to eq(current_users_friend)
            # non-contacts
            result[6..-1].each {|person|
              expect(person.contacts.where(user_id: current_user.id)).to be_empty
              expect(person.profile.first_name).to include("Ro")
            }
          end

          it "doesn't include people with non-matching names" do
            commenter = FactoryBot.create(:person, first_name: "RRR#{r_str}")
            FactoryBot.create(:comment, author: commenter)
            liker = FactoryBot.create(:person, first_name: "RRR#{r_str}")
            FactoryBot.create(:like, author: liker)
            friend = FactoryBot.create(:person, first_name: "RRR#{r_str}")
            current_user.contacts.create!(
              person:    friend,
              aspects:   [current_user.aspects.first],
              sharing:   true,
              receiving: true
            )

            result = post_service.mentionable_in_comment(post.id, "Ro")
            expect(result).not_to include(commenter)
            expect(result).not_to include(liker)
            expect(result).not_to include(friend)
          end
        end

        shared_examples "current user can't mention themself" do
          before do
            current_user.profile.update(first_name: "Ro#{r_str}")
          end

          it "doesn't include current user" do
            expect(post_service.mentionable_in_comment(post.id, "Ro")).not_to include(current_user.person)
          end
        end

        context "when current user is a post author" do
          let(:post_author) { current_user.person }

          include_examples "current user can't mention themself"
        end

        context "current user is a participant" do
          before do
            current_user.like!(post)
            current_user.comment!(post, "hello")
          end

          include_examples "current user can't mention themself"
        end

        context "current user is a stranger matching a search pattern" do
          include_examples "current user can't mention themself"
        end

        it "doesn't fail when the post author doesn't match the requested pattern" do
          expect(post_service.mentionable_in_comment(post.id, "#{r_str}#{r_str}#{r_str}")).to be_empty
        end

        it "renders a commenter with multiple comments only once" do
          person = FactoryBot.create(:person, first_name: "Ro2#{r_str}")
          2.times { FactoryBot.create(:comment, author: person, post: post) }
          expect(post_service.mentionable_in_comment(post.id, person.first_name).length).to eq(1)
        end
      end
    end

    describe "unit test" do
      let(:post_service) { PostService.new(alice) }

      before do
        expect(post_service).to receive(:find!).and_return(post)
      end

      it "calls Person.allowed_to_be_mentioned_in_a_comment_to" do
        expect(Person).to receive(:allowed_to_be_mentioned_in_a_comment_to).with(post).and_call_original
        post_service.mentionable_in_comment(post.id, "whatever")
      end

      it "calls Person.find_by_substring" do
        expect(Person).to receive(:find_by_substring).with("whatever").and_call_original
        post_service.mentionable_in_comment(post.id, "whatever")
      end

      it "calls Person.sort_for_mention_suggestion" do
        expect(Person).to receive(:sort_for_mention_suggestion).with(post, alice).and_call_original
        post_service.mentionable_in_comment(post.id, "whatever")
      end

      it "calls Person.limit" do
        16.times {
          FactoryBot.create(:comment, author: FactoryBot.create(:person, first_name: "Ro#{r_str}"), post: post)
        }
        expect(post_service.mentionable_in_comment(post.id, "Ro").length).to eq(15)
      end

      it "contains a constraint on a current user" do
        expect(Person).to receive(:allowed_to_be_mentioned_in_a_comment_to) { Person.all }
        expect(Person).to receive(:find_by_substring) { Person.all }
        expect(Person).to receive(:sort_for_mention_suggestion) { Person.all }
        expect(post_service.mentionable_in_comment(post.id, alice.person.first_name))
          .not_to include(alice.person)
      end
    end
  end
end

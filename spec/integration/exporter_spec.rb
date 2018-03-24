# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe Diaspora::Exporter do
  let(:user) { FactoryGirl.create(:user_with_aspect) }

  context "output json" do
    let(:json) { Diaspora::Exporter.new(user).execute }

    it "matches archive schema" do
      DataGenerator.create(
        user,
        %i[generic_user_data activity status_messages_flavours work_aspect]
      )

      expect(JSON.parse(json)).to match_json_schema(:archive_schema)
    end

    it "contains basic user data" do
      user_properties = build_property_hash(
        user,
        %i[email username language disable_mail show_community_spotlight_in_stream auto_follow_back
           auto_follow_back_aspect strip_exif],
        private_key: :serialized_private_key
      )

      user_properties[:profile] = {
        entity_type: "profile",
        entity_data: build_property_hash(
          user.profile,
          %i[first_name last_name gender bio location image_url birthday searchable nsfw tag_string],
          author: :diaspora_handle
        )
      }

      expect(json).to include_json(user: user_properties)
    end

    it "contains aspects" do
      DataGenerator.create(user, :work_aspect)

      expect(json).to include_json(
        user: {
          "contact_groups": [
            {
              "name":             "generic",
              "contacts_visible": true,
              "chat_enabled":     false
            },
            {
              "name":             "Work",
              "contacts_visible": false,
              "chat_enabled":     false
            }
          ]
        }
      )
    end

    it "contains contacts" do
      friends = DataGenerator.create(user, Array.new(2, :mutual_friend))
      serialized_contacts = friends.map {|friend|
        contact = Contact.find_by(person_id: friend.person_id)
        hash = build_property_hash(
          contact,
          %i[sharing receiving person_guid person_name],
          following: :sharing, followed: :receiving, account_id: :person_diaspora_handle
        )
        hash[:public_key] = contact.person.serialized_public_key
        hash[:contact_groups_membership] = contact.aspects.map(&:name)
        hash
      }

      expect(json).to include_json(user: {contacts: serialized_contacts})
    end

    it "contains a public status message" do
      status_message = FactoryGirl.create(:status_message, author: user.person, public: true)
      serialized = {
        "subscribed_pods_uris": [AppConfig.pod_uri.to_s],
        "entity_type":          "status_message",
        "entity_data":          {
          "author":     user.diaspora_handle,
          "guid":       status_message.guid,
          "created_at": status_message.created_at.iso8601,
          "text":       status_message.text,
          "public":     true
        }
      }

      expect(json).to include_json(user: {posts: [serialized]})
    end

    it "contains a status message with subscribers" do
      subscriber, status_message = DataGenerator.create(user, :status_message_with_subscriber)
      serialized = {
        "subscribed_users_ids": [subscriber.diaspora_handle],
        "entity_type":          "status_message",
        "entity_data":          {
          "author":     user.diaspora_handle,
          "guid":       status_message.guid,
          "created_at": status_message.created_at.iso8601,
          "text":       status_message.text,
          "public":     false
        }
      }

      expect(json).to include_json(user: {posts: [serialized]})
    end

    it "contains a status message with a poll" do
      status_message = FactoryGirl.create(:status_message_with_poll, author: user.person)
      serialized = {
        "entity_type": "status_message",
        "entity_data": {
          "author":     user.diaspora_handle,
          "guid":       status_message.guid,
          "created_at": status_message.created_at.iso8601,
          "text":       status_message.text,
          "poll":       {
            "entity_type": "poll",
            "entity_data": {
              "guid":         status_message.poll.guid,
              "question":     status_message.poll.question,
              "poll_answers": status_message.poll.poll_answers.map {|answer|
                {
                  "entity_type": "poll_answer",
                  "entity_data": {
                    "guid":   answer.guid,
                    "answer": answer.answer
                  }
                }
              }
            }
          },
          "public":     false
        }
      }

      expect(json).to include_json(user: {posts: [serialized]})
    end

    it "contains a status message with a photo" do
      status_message = FactoryGirl.create(:status_message_with_photo, author: user.person)

      serialized = {
        "entity_type": "status_message",
        "entity_data": {
          "author":     user.diaspora_handle,
          "guid":       status_message.guid,
          "created_at": status_message.created_at.iso8601,
          "text":       status_message.text,
          "photos":     [
            {
              "entity_type": "photo",
              "entity_data": {
                "guid":                status_message.photos.first.guid,
                "author":              user.diaspora_handle,
                "public":              false,
                "created_at":          status_message.photos.first.created_at.iso8601,
                "remote_photo_path":   "#{AppConfig.pod_uri}uploads\/images\/",
                "remote_photo_name":   status_message.photos.first.remote_photo_name,
                "status_message_guid": status_message.guid,
                "height":              42,
                "width":               23
              }
            }
          ],
          "public":     false
        }
      }

      expect(json).to include_json(user: {posts: [serialized]})
    end

    it "contains a status message with a location" do
      status_message = FactoryGirl.create(:status_message_with_location, author: user.person)

      serialized = {
        "entity_type": "status_message",
        "entity_data": {
          "author":     user.diaspora_handle,
          "guid":       status_message.guid,
          "created_at": status_message.created_at.iso8601,
          "text":       status_message.text,
          "location":   {
            "entity_type": "location",
            "entity_data": {
              "address": status_message.location.address,
              "lat":     status_message.location.lat,
              "lng":     status_message.location.lng
            }
          },
          "public":     false
        }
      }

      expect(json).to include_json(user: {posts: [serialized]})
    end

    it "contains a reshare" do
      reshare = FactoryGirl.create(:reshare, author: user.person)
      serialized_reshare = {
        "subscribed_pods_uris": [reshare.root.author.pod.url_to(""), AppConfig.pod_uri.to_s],
        "entity_type":          "reshare",
        "entity_data":          {
          "author":      user.diaspora_handle,
          "guid":        reshare.guid,
          "created_at":  reshare.created_at.iso8601,
          "root_author": reshare.root_author.diaspora_handle,
          "root_guid":   reshare.root_guid
        }
      }

      expect(json).to include_json(
        user: {posts: [serialized_reshare]}
      )
    end

    it "contains followed tags" do
      tag_following = DataGenerator.create(user, :tag_following)
      expect(json).to include_json(user: {followed_tags: [tag_following.tag.name]})
    end

    it "contains post subscriptions" do
      subscription = DataGenerator.create(user, :subscription)
      expect(json).to include_json(user: {post_subscriptions: [subscription.target.guid]})
    end

    it "contains a comment" do
      comment = FactoryGirl.create(:comment, author: user.person)
      serialized_comment = {
        "entity_type":    "comment",
        "entity_data":    {
          "author":      user.diaspora_handle,
          "guid":        comment.guid,
          "parent_guid": comment.parent.guid,
          "text":        comment.text,
          "created_at":  comment.created_at.iso8601
        },
        "property_order": %w[author guid parent_guid text created_at]
      }

      expect(json).to include_json(
        user: {relayables: [serialized_comment]}
      )
    end

    it "contains a like" do
      like = FactoryGirl.create(:like, author: user.person)
      serialized_like = {
        "entity_type":    "like",
        "entity_data":    {
          "author":      user.diaspora_handle,
          "guid":        like.guid,
          "parent_guid": like.parent.guid,
          "parent_type": like.target_type,
          "positive":    like.positive
        },
        "property_order": %w[author guid parent_guid parent_type positive]
      }

      expect(json).to include_json(
        user: {relayables: [serialized_like]}
      )
    end

    it "contains a poll participation" do
      poll_participation = FactoryGirl.create(:poll_participation, author: user.person)
      serialized_participation = {
        "entity_type":    "poll_participation",
        "entity_data":    {
          "author":           user.diaspora_handle,
          "guid":             poll_participation.guid,
          "parent_guid":      poll_participation.parent.guid,
          "poll_answer_guid": poll_participation.poll_answer.guid
        },
        "property_order": %w[author guid parent_guid poll_answer_guid]
      }

      expect(json).to include_json(
        user: {relayables: [serialized_participation]}
      )
    end

    it "contains a comment for the user's post" do
      status_message, comment = DataGenerator.create(user, :status_message_with_comment)
      serialized = {
        "entity_type":    "comment",
        "entity_data":    {
          "author":           comment.diaspora_handle,
          "guid":             comment.guid,
          "parent_guid":      status_message.guid,
          "text":             comment.text,
          "created_at":       comment.created_at.iso8601,
          "author_signature": Diaspora::Federation::Entities.build(comment).to_h[:author_signature]
        },
        "property_order": %w[author guid parent_guid text created_at]
      }

      expect(json).to include_json(others_data: {relayables: [serialized]})
    end

    it "contains a like for the user's post" do
      status_message, like = DataGenerator.create(user, :status_message_with_like)
      serialized = {
        "entity_type":    "like",
        "entity_data":    {
          "author":           like.diaspora_handle,
          "guid":             like.guid,
          "parent_guid":      status_message.guid,
          "parent_type":      like.target_type,
          "positive":         like.positive,
          "author_signature": Diaspora::Federation::Entities.build(like).to_h[:author_signature]
        },
        "property_order": %w[author guid parent_guid parent_type positive]
      }

      expect(json).to include_json(others_data: {relayables: [serialized]})
    end

    it "contains a poll participation for the user's post" do
      _, poll_participation = DataGenerator.create(user, :status_message_with_poll_participation)
      serialized = {
        "entity_type":    "poll_participation",
        "entity_data":    {
          "author":           poll_participation.diaspora_handle,
          "guid":             poll_participation.guid,
          "parent_guid":      poll_participation.parent.guid,
          "poll_answer_guid": poll_participation.poll_answer.guid,
          "author_signature": Diaspora::Federation::Entities.build(poll_participation).to_h[:author_signature]
        },
        "property_order": %w[author guid parent_guid poll_answer_guid]
      }

      expect(json).to include_json(others_data: {relayables: [serialized]})
    end

    def transform_value(value)
      return value.iso8601 if value.is_a? Date
      value
    end

    def build_property_hash(object, direct_properties, aliased_properties={})
      props = direct_properties.map {|key|
        [key, transform_value(object.send(key))]
      }.to_h

      aliased = aliased_properties.map {|key, key_alias|
        [key, object.send(key_alias)]
      }.to_h

      props.merge(aliased)
    end
  end
end

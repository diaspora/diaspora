module Diaspora
  module Federation
    module Receive
      def self.account_deletion(entity)
        AccountDeletion.new(
          person:          author_of(entity),
          diaspora_handle: entity.author
        ).tap(&:save!)
      end

      def self.comment(entity)
        Comment.new(
          author:      author_of(entity),
          guid:        entity.guid,
          created_at:  entity.created_at,
          text:        entity.text,
          commentable: Post.find_by(guid: entity.parent_guid)
        ).tap do |comment|
          comment.author_signature = entity.author_signature if comment.parent.author.local?
          comment.save!
        end
      end

      def self.contact(entity)
        recipient = Person.find_by(diaspora_handle: entity.recipient).owner
        contact = recipient.contacts.find_or_initialize_by(person_id: author_of(entity).id)

        return if contact.sharing

        contact.tap do |contact|
          contact.sharing = true
          contact.save!
        end
      end

      def self.conversation(entity)
        Conversation.new(
          author:              author_of(entity),
          guid:                entity.guid,
          subject:             entity.subject,
          created_at:          entity.created_at,
          participant_handles: entity.participants
        ).tap do |conversation|
          conversation.messages = entity.messages.map {|message| build_message(message) }
          conversation.save!
        end
      end

      def self.like(entity)
        Like.new(
          author:   author_of(entity),
          guid:     entity.guid,
          positive: entity.positive,
          target:   entity.parent_type.constantize.find_by(guid: entity.parent_guid)
        ).tap do |like|
          like.author_signature = entity.author_signature if like.parent.author.local?
          like.save!
        end
      end

      def self.message(entity)
        build_message(entity).tap(&:save!)
      end

      def self.participation(entity)
        parent = entity.parent_type.constantize.find_by(guid: entity.parent_guid)

        return unless parent.author.local?

        Participation.new(
          author: author_of(entity),
          guid:   entity.guid,
          target: entity.parent_type.constantize.find_by(guid: entity.parent_guid)
        ).tap(&:save!)
      end

      def self.photo(entity)
        build_photo(entity).tap(&:save!)
      end

      def self.poll_participation(entity)
        PollParticipation.new(
          author: author_of(entity),
          guid:   entity.guid,
          poll:   Poll.find_by(guid: entity.parent_guid)
        ).tap do |poll_participation|
          poll_participation.poll_answer_guid = entity.poll_answer_guid
          poll_participation.author_signature = entity.author_signature if poll_participation.parent.author.local?
          poll_participation.save!
        end
      end

      def self.reshare(entity)
        Reshare.new(
          author:                author_of(entity),
          guid:                  entity.guid,
          created_at:            entity.created_at,
          provider_display_name: entity.provider_display_name,
          public:                entity.public,
          root_guid:             entity.root_guid
        ).tap(&:save!)
      end

      def self.status_message(entity)
        StatusMessage.new(
          author:                author_of(entity),
          guid:                  entity.guid,
          raw_message:           entity.raw_message,
          public:                entity.public,
          created_at:            entity.created_at,
          provider_display_name: entity.provider_display_name
        ).tap do |status_message|
          status_message.photos = entity.photos.map {|photo| build_photo(photo) }
          status_message.location = build_location(entity.location) if entity.location
          status_message.poll = build_poll(entity.poll) if entity.poll

          status_message.save!
        end
      end

      private

      def self.author_of(entity)
        Person.find_by(diaspora_handle: entity.author)
      end

      def self.build_location(entity)
        Location.new(
          address: entity.address,
          lat:     entity.lat,
          lng:     entity.lng
        )
      end

      def self.build_message(entity)
        Message.new(
          author:            author_of(entity),
          guid:              entity.guid,
          text:              entity.text,
          created_at:        entity.created_at,
          conversation_guid: entity.conversation_guid
        )
      end

      def self.build_photo(entity)
        Photo.new(
          author:              author_of(entity),
          guid:                entity.guid,
          text:                entity.text,
          public:              entity.public,
          created_at:          entity.created_at,
          remote_photo_path:   entity.remote_photo_path,
          remote_photo_name:   entity.remote_photo_name,
          status_message_guid: entity.status_message_guid,
          height:              entity.height,
          width:               entity.width
        )
      end

      def self.build_poll(entity)
        Poll.new(
          guid:     entity.guid,
          question: entity.question
        ).tap do |poll|
          poll.poll_answers = entity.poll_answers.map do |answer|
            PollAnswer.new(
              guid:   answer.guid,
              answer: answer.answer
            )
          end
        end
      end
    end
  end
end

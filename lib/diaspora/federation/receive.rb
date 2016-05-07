module Diaspora
  module Federation
    module Receive
      extend Diaspora::Logging

      def self.account_deletion(entity)
        AccountDeletion.new(
          person:          author_of(entity),
          diaspora_handle: entity.author
        ).tap(&:save!)
      end

      def self.comment(entity)
        author = author_of(entity)
        ignore_existing_guid(Comment, entity.guid, author) do
          Comment.new(
            author:      author,
            guid:        entity.guid,
            created_at:  entity.created_at,
            text:        entity.text,
            commentable: Post.find_by(guid: entity.parent_guid)
          ).tap {|comment| save_relayable(comment, entity) }
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
        author = author_of(entity)
        try_load_existing_guid(Conversation, entity.guid, author) do
          Conversation.new(
            author:              author,
            guid:                entity.guid,
            subject:             entity.subject,
            created_at:          entity.created_at,
            participant_handles: entity.participants
          ).tap do |conversation|
            conversation.messages = entity.messages.map {|message| build_message(message) }
            conversation.save!
          end
        end
      end

      def self.like(entity)
        author = author_of(entity)
        ignore_existing_guid(Like, entity.guid, author) do
          Like.new(
            author:   author,
            guid:     entity.guid,
            positive: entity.positive,
            target:   entity.parent_type.constantize.find_by(guid: entity.parent_guid)
          ).tap {|like| save_relayable(like, entity) }
        end
      end

      def self.message(entity)
        ignore_existing_guid(Message, entity.guid, author_of(entity)) do
          build_message(entity).tap(&:save!)
        end
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
        author = author_of(entity)
        ignore_existing_guid(PollParticipation, entity.guid, author) do
          PollParticipation.new(
            author: author,
            guid:   entity.guid,
            poll:   Poll.find_by(guid: entity.parent_guid)
          ).tap do |poll_participation|
            poll_participation.poll_answer_guid = entity.poll_answer_guid

            save_relayable(poll_participation, entity)
          end
        end
      end

      def self.profile(entity)
        author_of(entity).profile.tap do |profile|
          profile.update_attributes(
            first_name:       entity.first_name,
            last_name:        entity.last_name,
            image_url:        entity.image_url,
            image_url_medium: entity.image_url_medium,
            image_url_small:  entity.image_url_small,
            birthday:         entity.birthday,
            gender:           entity.gender,
            bio:              entity.bio,
            location:         entity.location,
            searchable:       entity.searchable,
            nsfw:             entity.nsfw,
            tag_string:       entity.tag_string
          )
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
        author = author_of(entity)
        try_load_existing_guid(StatusMessage, entity.guid, author) do
          StatusMessage.new(
            author:                author,
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
      end

      def self.author_of(entity)
        Person.find_by(diaspora_handle: entity.author)
      end
      private_class_method :author_of

      def self.build_location(entity)
        Location.new(
          address: entity.address,
          lat:     entity.lat,
          lng:     entity.lng
        )
      end
      private_class_method :build_location

      def self.build_message(entity)
        Message.new(
          author:            author_of(entity),
          guid:              entity.guid,
          text:              entity.text,
          created_at:        entity.created_at,
          conversation_guid: entity.conversation_guid
        )
      end
      private_class_method :build_message

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
      private_class_method :build_photo

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
      private_class_method :build_poll

      def self.save_relayable(relayable, entity)
        retract_if_author_ignored(relayable)

        relayable.author_signature = entity.author_signature if relayable.parent.author.local?
        relayable.save!
      end
      private_class_method :save_relayable

      def self.retract_if_author_ignored(relayable)
        parent_author = relayable.parent.author
        return unless parent_author.local? && parent_author.owner.ignored_people.include?(relayable.author)

        # TODO: send retraction

        raise Diaspora::Federation::AuthorIgnored
      end
      private_class_method :retract_if_author_ignored

      # check if the object already exists, otherwise save it.
      # if save fails (probably because of a second object received parallel),
      # check again if an object with the same guid already exists, but maybe has a different author.
      # @raise [InvalidAuthor] if the author of the existing object doesn't match
      def self.ignore_existing_guid(klass, guid, author)
        yield unless klass.where(guid: guid, author_id: author.id).exists?
      rescue => e
        raise e unless load_from_database(klass, guid, author)
        logger.warn "ignoring error on receive #{klass}:#{guid}: #{e.class}: #{e.message}"
      end
      private_class_method :ignore_existing_guid

      # try to load the object first from the DB and if not available, save it.
      # if save fails (probably because of a second object received parallel),
      # try again to load it, because it is possibly there now.
      # @raise [InvalidAuthor] if the author of the existing object doesn't match
      def self.try_load_existing_guid(klass, guid, author)
        load_from_database(klass, guid, author) || yield
      rescue Diaspora::Federation::InvalidAuthor => e
        raise e # don't try loading from db twice
      rescue => e
        logger.warn "failed to save #{klass}:#{guid} (#{e.class}: #{e.message}) - try loading it from DB"
        load_from_database(klass, guid, author).tap do |object|
          raise e unless object
        end
      end
      private_class_method :try_load_existing_guid

      # @raise [InvalidAuthor] if the author of the loaded object doesn't match
      def self.load_from_database(klass, guid, author)
        klass.find_by(guid: guid).tap do |object|
          if object && object.author_id != author.id
            raise Diaspora::Federation::InvalidAuthor, "#{klass}:#{guid}: #{author.diaspora_handle}"
          end
        end
      end
      private_class_method :load_from_database
    end
  end
end

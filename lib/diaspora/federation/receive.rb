module Diaspora
  module Federation
    module Receive
      extend Diaspora::Logging

      def self.perform(entity)
        public_send(Mappings.receiver_for(entity.class), entity)
      end

      def self.account_deletion(entity)
        AccountDeletion.create!(person: author_of(entity), diaspora_handle: entity.author)
      end

      def self.comment(entity)
        receive_relayable(Comment, entity) do
          Comment.new(
            author:      author_of(entity),
            guid:        entity.guid,
            created_at:  entity.created_at,
            text:        entity.text,
            commentable: Post.find_by(guid: entity.parent_guid)
          )
        end
      end

      def self.contact(entity)
        recipient = Person.find_by(diaspora_handle: entity.recipient).owner
        if entity.sharing.to_s == "true"
          Contact.create_or_update_sharing_contact(recipient, author_of(entity))
        else
          recipient.disconnected_by(author_of(entity))
          nil
        end
      end

      def self.conversation(entity)
        author = author_of(entity)
        ignore_existing_guid(Conversation, entity.guid, author) do
          Conversation.create!(
            author:              author,
            guid:                entity.guid,
            subject:             entity.subject,
            created_at:          entity.created_at,
            participant_handles: entity.participants,
            messages:            entity.messages.map {|message| build_message(message) }
          )
        end
      end

      def self.like(entity)
        receive_relayable(Like, entity) do
          Like.new(
            author:   author_of(entity),
            guid:     entity.guid,
            positive: entity.positive,
            target:   Mappings.model_class_for(entity.parent_type).find_by(guid: entity.parent_guid)
          )
        end
      end

      def self.message(entity)
        save_message(entity).tap {|message| relay_relayable(message) if message }
      end

      def self.participation(entity)
        author = author_of(entity)
        ignore_existing_guid(Participation, entity.guid, author) do
          Participation.create!(
            author: author,
            guid:   entity.guid,
            target: Mappings.model_class_for(entity.parent_type).find_by(guid: entity.parent_guid)
          )
        end
      end

      def self.photo(entity)
        author = author_of(entity)
        persisted_photo = load_from_database(Photo, entity.guid, author)

        if persisted_photo
          persisted_photo.tap do |photo|
            photo.update_attributes(
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
        else
          save_photo(entity)
        end
      end

      def self.poll_participation(entity)
        receive_relayable(PollParticipation, entity) do
          PollParticipation.new(
            author:           author_of(entity),
            guid:             entity.guid,
            poll:             Poll.find_by(guid: entity.parent_guid),
            poll_answer_guid: entity.poll_answer_guid
          )
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
        author = author_of(entity)
        ignore_existing_guid(Reshare, entity.guid, author) do
          Reshare.create!(
            author:                author,
            guid:                  entity.guid,
            created_at:            entity.created_at,
            provider_display_name: entity.provider_display_name,
            public:                entity.public,
            root_guid:             entity.root_guid
          )
        end
      end

      def self.retraction(entity, recipient_id)
        model_class = Diaspora::Federation::Mappings.model_class_for(entity.target_type)
        object = model_class.where(guid: entity.target_guid).take!

        case object
        when Person
          User.find(recipient_id).disconnected_by(object)
        when Diaspora::Relayable
          if object.parent.author.local?
            parent_author = object.parent.author.owner
            retraction = Retraction.for(object, parent_author)
            retraction.defer_dispatch(parent_author, false)
            retraction.perform
          else
            object.destroy!
          end
        else
          object.destroy!
        end
      end

      def self.status_message(entity)
        try_load_existing_guid(StatusMessage, entity.guid, author_of(entity)) do
          StatusMessage.new(
            author:                author_of(entity),
            guid:                  entity.guid,
            text:                  entity.text,
            public:                entity.public,
            created_at:            entity.created_at,
            provider_display_name: entity.provider_display_name
          ).tap do |status_message|
            status_message.location = build_location(entity.location) if entity.location
            status_message.poll = build_poll(entity.poll) if entity.poll
            status_message.photos = save_or_load_photos(entity.photos)

            status_message.save!
          end
        end
      end

      private_class_method def self.author_of(entity)
        Person.by_account_identifier(entity.author)
      end

      private_class_method def self.build_location(entity)
        Location.new(
          address: entity.address,
          lat:     entity.lat,
          lng:     entity.lng
        )
      end

      private_class_method def self.build_message(entity)
        Message.new(
          author:            author_of(entity),
          guid:              entity.guid,
          text:              entity.text,
          created_at:        entity.created_at,
          conversation_guid: entity.conversation_guid
        )
      end

      private_class_method def self.build_poll(entity)
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

      private_class_method def self.save_message(entity)
        ignore_existing_guid(Message, entity.guid, author_of(entity)) do
          build_message(entity).tap do |message|
            message.author_signature = entity.author_signature if message.conversation.author.local?
            message.save!
          end
        end
      end

      private_class_method def self.save_photo(entity)
        Photo.create!(
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

      private_class_method def self.save_or_load_photos(photos)
        photos.map do |photo|
          try_load_existing_guid(Photo, photo.guid, author_of(photo)) { save_photo(photo) }
        end
      end

      private_class_method def self.receive_relayable(klass, entity)
        save_relayable(klass, entity) { yield }.tap {|relayable| relay_relayable(relayable) if relayable }
      end

      private_class_method def self.save_relayable(klass, entity)
        ignore_existing_guid(klass, entity.guid, author_of(entity)) do
          yield.tap do |relayable|
            retract_if_author_ignored(relayable)

            relayable.signature = build_signature(klass, entity) if relayable.parent.author.local?
            relayable.save!
          end
        end
      end

      private_class_method def self.build_signature(klass, entity)
        klass.reflect_on_association(:signature).klass.new(
          author_signature: entity.author_signature,
          additional_data:  entity.additional_xml_elements,
          signature_order:  SignatureOrder.find_or_create_by!(order: entity.xml_order.join(" "))
        )
      end

      private_class_method def self.retract_if_author_ignored(relayable)
        parent_author = relayable.parent.author.owner
        return unless parent_author && parent_author.ignored_people.include?(relayable.author)

        retraction = Retraction.for(relayable, parent_author)
        Diaspora::Federation::Dispatcher.build(parent_author, retraction, subscribers: [relayable.author]).dispatch

        raise Diaspora::Federation::AuthorIgnored
      end

      private_class_method def self.relay_relayable(relayable)
        parent_author = relayable.parent.author.owner
        Diaspora::Federation::Dispatcher.defer_dispatch(parent_author, relayable) if parent_author
      end

      # check if the object already exists, otherwise save it.
      # if save fails (probably because of a second object received parallel),
      # check again if an object with the same guid already exists, but maybe has a different author.
      # @raise [InvalidAuthor] if the author of the existing object doesn't match
      private_class_method def self.ignore_existing_guid(klass, guid, author)
        yield unless klass.where(guid: guid, author_id: author.id).exists?
      rescue => e
        raise e unless load_from_database(klass, guid, author)
        logger.warn "ignoring error on receive #{klass}:#{guid}: #{e.class}: #{e.message}"
        nil
      end

      # try to load the object first from the DB and if not available, save it.
      # if save fails (probably because of a second object received parallel),
      # try again to load it, because it is possibly there now.
      # @raise [InvalidAuthor] if the author of the existing object doesn't match
      private_class_method def self.try_load_existing_guid(klass, guid, author)
        load_from_database(klass, guid, author) || yield
      rescue Diaspora::Federation::InvalidAuthor => e
        raise e # don't try loading from db twice
      rescue => e
        logger.warn "failed to save #{klass}:#{guid} (#{e.class}: #{e.message}) - try loading it from DB"
        load_from_database(klass, guid, author).tap do |object|
          raise e unless object
        end
      end

      # @raise [InvalidAuthor] if the author of the loaded object doesn't match
      private_class_method def self.load_from_database(klass, guid, author)
        klass.find_by(guid: guid).tap do |object|
          if object && object.author_id != author.id
            raise Diaspora::Federation::InvalidAuthor, "#{klass}:#{guid}: #{author.diaspora_handle}"
          end
        end
      end
    end
  end
end

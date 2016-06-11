module Diaspora
  module Federation
    def self.post(post)
      case post
      when StatusMessage
        status_message(post)
      when Reshare
        reshare(post)
      else
        raise ArgumentError, "unknown post-class: #{post.class}"
      end
    end

    def self.location(location)
      DiasporaFederation::Entities::Location.new(
        address: location.address,
        lat:     location.lat,
        lng:     location.lng
      )
    end

    def self.photo(photo)
      DiasporaFederation::Entities::Photo.new(
        author:              photo.diaspora_handle,
        guid:                photo.guid,
        public:              photo.public,
        created_at:          photo.created_at,
        remote_photo_path:   photo.remote_photo_path,
        remote_photo_name:   photo.remote_photo_name,
        text:                photo.text,
        status_message_guid: photo.status_message_guid,
        height:              photo.height,
        width:               photo.width
      )
    end

    def self.poll(poll)
      DiasporaFederation::Entities::Poll.new(
        guid:         poll.guid,
        question:     poll.question,
        poll_answers: poll.poll_answers.map {|answer| poll_answer(answer) }
      )
    end

    def self.poll_answer(poll_answer)
      DiasporaFederation::Entities::PollAnswer.new(
        guid:   poll_answer.guid,
        answer: poll_answer.answer
      )
    end

    def self.reshare(reshare)
      DiasporaFederation::Entities::Reshare.new(
        root_author:           reshare.root_diaspora_id,
        root_guid:             reshare.root_guid,
        author:                reshare.diaspora_handle,
        guid:                  reshare.guid,
        public:                reshare.public,
        created_at:            reshare.created_at,
        provider_display_name: reshare.provider_display_name
      )
    end

    def self.status_message(status_message)
      DiasporaFederation::Entities::StatusMessage.new(
        author:                status_message.diaspora_handle,
        guid:                  status_message.guid,
        raw_message:           status_message.raw_message,
        photos:                status_message.photos.map {|photo| photo(photo) },
        location:              status_message.location ? location(status_message.location) : nil,
        poll:                  status_message.poll ? poll(status_message.poll) : nil,
        public:                status_message.public,
        created_at:            status_message.created_at,
        provider_display_name: status_message.provider_display_name
      )
    end
  end
end

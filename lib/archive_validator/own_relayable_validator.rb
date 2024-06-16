# frozen_string_literal: true

class ArchiveValidator
  class OwnRelayableValidator < RelayableValidator
    private

    def post_find_by_guid(guid)
      super || by_guid(Post, guid)
    end

    def post_find_by_poll_guid(guid)
      super || by_guid(Poll, guid)&.status_message
    end

    def by_guid(klass, guid)
      klass.find_or_fetch_by(archive_author_diaspora_id, guid)
    end
  end
end

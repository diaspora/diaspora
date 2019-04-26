# frozen_string_literal: true

class ArchiveImporter
  class OwnEntityImporter < EntityImporter
    def import
      substitute_author
      super
    rescue Diaspora::Federation::InvalidAuthor
      return if real_author == old_author_id

      logger.warn "#{self.class}: attempt to import an entity with guid \"#{guid}\" which belongs to #{real_author}"
    end

    private

    def substitute_author
      @old_author_id = entity_data["author"]
      entity_data["author"] = user.diaspora_handle
    end

    attr_reader :old_author_id

    def persisted_object
      @persisted_object ||= (instance if real_author == old_author_id)
    end

    def real_author
      instance.author.diaspora_handle
    end
  end
end

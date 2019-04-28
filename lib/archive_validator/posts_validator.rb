# frozen_string_literal: true

class ArchiveValidator
  class PostsValidator < CollectionValidator
    def collection
      posts
    end

    def entity_validator
      PostValidator
    end
  end
end

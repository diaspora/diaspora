# frozen_string_literal: true

class CleanupEmptySignatures < ActiveRecord::Migration[5.1]
  class Comment < ApplicationRecord
    belongs_to :commentable, polymorphic: true

    has_one :signature, class_name: "CommentSignature", dependent: :delete

    before_destroy do
      Like.where(target_type: "Comment", target_id: id).destroy_all
      ActsAsTaggableOn::Tagging.where(taggable_type: "Comment", taggable_id: id).destroy_all
    end

    after_destroy do
      commentable.update_comments_counter
    end
  end

  class Like < ApplicationRecord
    belongs_to :target, polymorphic: true

    has_one :signature, class_name: "LikeSignature", dependent: :delete

    after_destroy do
      target.update_likes_counter
    end
  end

  class PollParticipation < ApplicationRecord
    belongs_to :poll_answer, counter_cache: :vote_count

    has_one :signature, class_name: "PollParticipationSignature", dependent: :delete
  end

  def up
    Comment.joins("INNER JOIN comment_signatures as signature ON comments.id = signature.comment_id")
           .where("signature.author_signature = ''").destroy_all
    Like.joins("INNER JOIN like_signatures as signature ON likes.id = signature.like_id")
        .where("signature.author_signature = ''").destroy_all
    PollParticipation.joins("INNER JOIN poll_participation_signatures as signature " \
                            "ON poll_participations.id = signature.poll_participation_id")
                     .where("signature.author_signature = ''").destroy_all
  end
end

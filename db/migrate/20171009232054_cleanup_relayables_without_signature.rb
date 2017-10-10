# frozen_string_literal: true

class CleanupRelayablesWithoutSignature < ActiveRecord::Migration[5.1]
  class Comment < ApplicationRecord
    belongs_to :commentable, polymorphic: true

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
  end

  def up
    cleanup_comments
    cleanup_likes
    cleanup_poll_participations
  end

  def cleanup_comments
    Comment.joins("INNER JOIN posts as post ON post.id = comments.commentable_id AND " \
                  "comments.commentable_type = 'Post'")
           .joins("INNER JOIN people as comment_author ON comment_author.id = comments.author_id")
           .joins("INNER JOIN people as post_author ON post_author.id = post.author_id")
           .where("comment_author.owner_id IS NULL AND post_author.owner_id IS NOT NULL " \
                  "AND NOT EXISTS(" \
                    "SELECT NULL FROM comment_signatures WHERE comment_signatures.comment_id = comments.id" \
                  ")")
           .destroy_all
  end

  def cleanup_likes
    Like.joins("INNER JOIN posts as post ON post.id = likes.target_id AND likes.target_type = 'Post'")
        .joins("INNER JOIN people as like_author ON like_author.id = likes.author_id")
        .joins("INNER JOIN people as post_author ON post_author.id = post.author_id")
        .where("like_author.owner_id IS NULL AND post_author.owner_id IS NOT NULL " \
               "AND NOT EXISTS(" \
                 "SELECT NULL FROM like_signatures WHERE like_signatures.like_id = likes.id" \
               ")")
        .destroy_all
    Like.joins("INNER JOIN comments as comment ON comment.id = likes.target_id AND likes.target_type = 'Comment'")
        .joins("INNER JOIN posts as post ON post.id = comment.commentable_id AND comment.commentable_type = 'Post'")
        .joins("INNER JOIN people as like_author ON like_author.id = likes.author_id")
        .joins("INNER JOIN people as post_author ON post_author.id = post.author_id")
        .where("like_author.owner_id IS NULL AND post_author.owner_id IS NOT NULL " \
               "AND NOT EXISTS(" \
                 "SELECT NULL FROM like_signatures WHERE like_signatures.like_id = likes.id" \
               ")")
        .destroy_all
  end

  def cleanup_poll_participations
    PollParticipation.joins("INNER JOIN polls as poll ON poll.id = poll_participations.poll_id")
                     .joins("INNER JOIN posts as post ON post.id = poll.status_message_id")
                     .joins("INNER JOIN people as pp_author ON pp_author.id = poll_participations.author_id")
                     .joins("INNER JOIN people as post_author ON post_author.id = post.author_id")
                     .where("pp_author.owner_id IS NULL AND post_author.owner_id IS NOT NULL " \
                            "AND NOT EXISTS(" \
                              "SELECT NULL FROM poll_participation_signatures " \
                              "WHERE poll_participation_signatures.poll_participation_id = poll_participations.id" \
                            ")")
                     .destroy_all
  end
end

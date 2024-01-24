# frozen_string_literal: true

class Report < ApplicationRecord
  validates :user_id, presence: true
  validates :item_id, presence: true
  validates :item_type, presence: true, inclusion: {
    in: %w[Post Comment], message: "Type should match `Post` or `Comment`!"
  }
  validates :text, presence: true

  validate :entry_does_not_exist, on: :create
  validate :post_or_comment_does_exist, on: :create

  belongs_to :user
  belongs_to :post, optional: true
  belongs_to :comment, optional: true
  belongs_to :item, polymorphic: true

  STATUS_DELETED = "deleted"
  STATUS_NO_ACTION = "no_action"

  after_commit :send_report_notification, on: :create

  scope :join_originator, -> {
    joins("LEFT JOIN people ON reported_author_id = people.id ")
      .select("reports.*, people.diaspora_handle as reported_author, people.guid as reported_author_guid")
  }

  def reported_author
    return Person.find(reported_author_id) if reported_author_id.present?

    item&.author
  end

  def entry_does_not_exist
    return unless Report.where(item_id: item_id, item_type: item_type).exists?(user_id: user_id)

    errors[:base] << "You cannot report the same post twice."
  end

  def post_or_comment_does_exist
    return unless Post.find_by(id: item_id).nil? && Comment.find_by(id: item_id).nil?

    errors[:base] << "Post or comment was already deleted or doesn't exists."
  end

  def destroy_reported_item
    case item
    when Post
      if item.author.local?
        item.author.owner.retract(item)
      else
        item.destroy
      end
    when Comment
      if item.author.local?
        item.author.owner.retract(item)
      elsif item.parent.author.local?
        item.parent.author.owner.retract(item)
      else
        item.destroy
      end
    end
    mark_as_reviewed(STATUS_DELETED)
  end

  # rubocop:disable Rails/SkipsModelValidations

  def mark_as_reviewed(with_action=STATUS_NO_ACTION)
    Report.where(item_id: item_id, item_type: item_type)
          .update_all(reviewed: true, action: with_action)
  end
  # rubocop:enable Rails/SkipsModelValidations

  def send_report_notification
    Workers::Mail::ReportWorker.perform_async(id)
  end
end

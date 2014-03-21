class Report < ActiveRecord::Base
  validates :user_id, presence: true
  validates :post_id, presence: true
  validates :post_type, presence: true
  validates :text, presence: true

  validate :entry_exists, :on => :create

  belongs_to :user
  belongs_to :post
  belongs_to :comment

  after_create :send_report_notification

  def entry_exists
    if Report.where(post_id: post_id, post_type: post_type).exists?(user_id: user_id)
      errors[:base] << 'You cannot report the same post twice.'
    end
  end

  def destroy_reported_item
    if post_type == 'post'
      delete_post
    elsif post_type == 'comment'
      delete_comment
    end
    mark_as_reviewed
  end
 
  def delete_post
    if post = Post.where(id: post_id).first
      if post.author.local?
        post.author.owner.retract(post)
      else
        post.destroy
      end
    end
  end
   
  def delete_comment
    if comment = Comment.where(id: post_id).first
      if comment.author.local?
        comment.author.owner.retract(comment)
      elsif comment.parent.author.local?
        comment.parent.author.owner.retract(comment)
      else
        comment.destroy
      end
    end
  end

  def mark_as_reviewed
    if reports = Report.where(post_id: post_id, post_type: post_type)
      reports.update_all(reviewed: true)
    end
  end

  def send_report_notification
    Workers::Mail::ReportWorker.perform_async(self.post_type, self.post_id)
  end
end

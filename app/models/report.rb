class Report < ActiveRecord::Base
  validates :user_id, presence: true
  validates :item_id, presence: true
  validates :item_type, presence: true, :inclusion => { :in => %w(post comment),
    :message => 'Type should match `post` or `comment`!'}
  validates :text, presence: true

  validate :entry_does_not_exist, :on => :create
  validate :post_or_comment_does_exist, :on => :create

  belongs_to :user
  belongs_to :post
  belongs_to :comment

  after_commit :send_report_notification, :on => :create

  def entry_does_not_exist
    if Report.where(item_id: item_id, item_type: item_type).exists?(user_id: user_id)
      errors[:base] << 'You cannot report the same post twice.'
    end
  end

  def post_or_comment_does_exist
    if Post.find_by_id(item_id).nil? && Comment.find_by_id(item_id).nil?
      errors[:base] << 'Post or comment was already deleted or doesn\'t exists.'
    end
  end

  def destroy_reported_item
    if item_type == 'post'
      delete_post
    elsif item_type == 'comment'
      delete_comment
    end
    mark_as_reviewed
  end
 
  def delete_post
    if post = Post.where(id: item_id).first
      if post.author.local?
        post.author.owner.retract(post)
      else
        post.destroy
      end
    end
  end
   
  def delete_comment
    if comment = Comment.where(id: item_id).first
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
    Report.where(item_id: item_id, item_type: item_type).update_all(reviewed: true)
  end

  def send_report_notification
    Workers::Mail::ReportWorker.perform_async(self.item_type, self.item_id)
  end
end

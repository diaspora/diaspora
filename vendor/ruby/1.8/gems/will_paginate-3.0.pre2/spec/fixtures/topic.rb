class Topic < ActiveRecord::Base
  has_many :replies, :dependent => :destroy, :order => 'replies.created_at DESC'
  belongs_to :project

  scope :mentions_activerecord, :conditions => ['topics.title LIKE ?', '%ActiveRecord%']
  scope :distinct, :select => "DISTINCT #{table_name}.*"
end

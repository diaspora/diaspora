class Poll < ActiveRecord::Base
  attr_accessible :question

  belongs_to :status_message
  belongs_to :author, :class_name => :person, :foreign_key => :author_id
  #has_many :poll_answers
end

class NoteExtension < ActiveRecord::Base
  belongs_to :note, :foreign_key => :post_id

  validates_presence_of :note
end

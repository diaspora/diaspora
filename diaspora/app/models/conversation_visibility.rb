class ConversationVisibility < ActiveRecord::Base

  belongs_to :conversation
  belongs_to :person

end

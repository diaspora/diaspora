class PrivateMessageVisibility < ActiveRecord::Base

  belongs_to :private_message
  belongs_to :person

end

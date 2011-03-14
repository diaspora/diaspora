class UserPreference < ActiveRecord::Base
  belongs_to :user

  validate :must_be_valid_email_type
  

  def must_be_valid_email_type
    unless valid_email_types.include?(self.email_type)
      errors.add(:email_type, 'supplied mail type is not a valid or known email type')
    end
  end

  def valid_email_types
    ["mentioned",
   "comment_on_post",
   "private_message",
   "request_acceptence",
   "request_received",
   "also_commented"]
  end
end

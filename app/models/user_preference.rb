class UserPreference < ActiveRecord::Base
  belongs_to :user

  validate :must_be_valid_email_type

  VALID_EMAIL_TYPES =
    ["someone_reported",
   "mentioned",
   "comment_on_post",
   "private_message",
   "started_sharing",
   "also_commented",
   "liked",
   "reshared"]

  def must_be_valid_email_type
    unless VALID_EMAIL_TYPES.include?(self.email_type)
      errors.add(:email_type, 'supplied mail type is not a valid or known email type')
    end
  end
end

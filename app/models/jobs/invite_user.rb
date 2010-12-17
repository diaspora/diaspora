module Jobs
  class InviteUser
    extend ResqueJobLogging
    @queue = :mail
    def self.perform(sender_id, email, aspect_id, invite_message)
      user = User.find(sender_id)
      user.invite_user(email, aspect_id, invite_message)
    end
  end
end

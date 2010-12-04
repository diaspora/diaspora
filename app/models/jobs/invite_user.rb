module Jobs
  class InviteUser
    @queue = :email
    def self.perform(sender_id, email, aspect_id, invite_message)
      user = User.find(sender_id)
      user.invite_user(email, aspect_id, invite_message)
    end
  end
end

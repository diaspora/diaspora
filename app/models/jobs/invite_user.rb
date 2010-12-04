module Jobs
  class InviteUser
    @queue = :email
    def self.perform(sender_id, params)
      user = User.find(sender_id)
      user.invite_user(params)
    end
  end
end

module Jobs
  class ReceiveSalmon
    @queue = :receive_salmon
    def self.perform(user_id, xml)
      user = User.find(user_id)
      user.receive_salmon(xml)
    end
  end
end

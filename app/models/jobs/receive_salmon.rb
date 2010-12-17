module Jobs
  class ReceiveSalmon
    extend ResqueJobLogging
    @queue = :receive_salmon
    def self.perform(user_id, xml)
      user = User.find(user_id)
      user.receive_salmon(xml)
    end
  end
end

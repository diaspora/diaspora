module Jobs
  class Receive
    extend ResqueJobLogging
    @queue = :receive
    def self.perform(user_id, xml, salmon_author_id)
      user = User.find(user_id)
      salmon_author = Person.find(salmon_author_id)
      user.receive(xml, salmon_author) if user and salmon_author
    end
  end
end

module Jobs
  class ReceiveLocal
    extend ResqueJobLogging
    @queue = :receive_local
    def self.perform(user_id, person_id, object_type, object_id)
      user = User.find(user_id)
      person = Person.find(person_id)
      object = object_type.constantize.first(:id => object_id)

      user.receive_object(object, person)
    end
  end
end

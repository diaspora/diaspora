class String
  def to_id
    BSON::ObjectID self
  end
end
class BSON::ObjectID
  def to_id
    self
  end
end
